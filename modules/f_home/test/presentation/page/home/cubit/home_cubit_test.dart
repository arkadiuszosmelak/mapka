import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:d_location/d_location.dart';
import 'package:f_home/presentation/page/home/cubit/home_cubit.dart';
import 'package:f_home/presentation/page/home/cubit/home_presentation_event.dart';
import 'package:f_home/presentation/page/home/cubit/home_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'home_cubit_test.mocks.dart';

UserLocation _fix({double latitude = 51.1, double longitude = 17.0}) {
  return UserLocation(
    latitude: latitude,
    longitude: longitude,
    accuracy: 5,
    speed: 0,
    heading: null,
    timestamp: DateTime(2024),
  );
}

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<LocationService>()])
void main() {
  late MockLocationService service;

  setUpAll(() {
    provideDummy<Result<bool>>(const Result<bool>.success(true));
  });

  setUp(() {
    service = MockLocationService();
  });

  // Collects presentation events emitted while [action] runs.
  Future<List<HomePresentationEvent>> capturePresentation(
    HomeCubit cubit,
    Future<void> Function() action,
  ) async {
    final List<HomePresentationEvent> events = <HomePresentationEvent>[];
    final StreamSubscription<HomePresentationEvent> sub = cubit.presentation.listen(events.add);
    await action();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await sub.cancel();
    return events;
  }

  group('startTracking', () {
    blocTest<HomeCubit, HomeState>(
      'emits [requesting, tracking, tracking+location] when permission is granted',
      build: () {
        when(service.ensurePermission()).thenAnswer((_) async => const Result<bool>.success(true));
        when(service.positionStream(distanceFilterMeters: anyNamed('distanceFilterMeters')))
            .thenAnswer((_) => Stream<UserLocation>.fromIterable(<UserLocation>[_fix()]));
        return HomeCubit(service);
      },
      act: (HomeCubit cubit) => cubit.startTracking(),
      expect: () => <HomeState>[
        const HomeState(status: LocationTrackingStatus.requesting),
        const HomeState(status: LocationTrackingStatus.tracking),
        HomeState(status: LocationTrackingStatus.tracking, location: _fix()),
      ],
    );

    test('emits RecenterRequested only on the first fix', () async {
      when(service.ensurePermission()).thenAnswer((_) async => const Result<bool>.success(true));
      when(service.positionStream(distanceFilterMeters: anyNamed('distanceFilterMeters')))
          .thenAnswer((_) => Stream<UserLocation>.fromIterable(<UserLocation>[_fix(), _fix(latitude: 51.2)]));
      final HomeCubit cubit = HomeCubit(service);

      final List<HomePresentationEvent> events = await capturePresentation(cubit, cubit.startTracking);

      expect(events.whereType<RecenterRequested>().length, 1);
      await cubit.close();
    });

    test('uses the last known location for an instant first fix', () async {
      when(service.ensurePermission()).thenAnswer((_) async => const Result<bool>.success(true));
      when(service.lastKnownLocation()).thenAnswer((_) async => _fix(latitude: 50.1));
      when(service.positionStream(distanceFilterMeters: anyNamed('distanceFilterMeters')))
          .thenAnswer((_) => const Stream<UserLocation>.empty());
      final HomeCubit cubit = HomeCubit(service);

      final List<HomePresentationEvent> events = await capturePresentation(cubit, cubit.startTracking);

      expect(cubit.state.location, isNotNull);
      expect(events.whereType<RecenterRequested>().length, 1);
      await cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'emits [requesting, denied] when permission is denied',
      build: () {
        when(service.ensurePermission())
            .thenAnswer((_) async => const Result<bool>.failure(LocationError('denied')));
        return HomeCubit(service);
      },
      act: (HomeCubit cubit) => cubit.startTracking(),
      expect: () => const <HomeState>[
        HomeState(status: LocationTrackingStatus.requesting),
        HomeState(status: LocationTrackingStatus.denied),
      ],
      verify: (_) => verifyNever(service.positionStream(distanceFilterMeters: anyNamed('distanceFilterMeters'))),
    );

    test('emits HomeLocationDenied with canOpenSettings on permanent denial', () async {
      when(service.ensurePermission())
          .thenAnswer((_) async => const Result<bool>.failure(LocationError('nope', permanentlyDenied: true)));
      final HomeCubit cubit = HomeCubit(service);

      final List<HomePresentationEvent> events = await capturePresentation(cubit, cubit.startTracking);

      expect(events, hasLength(1));
      final HomePresentationEvent event = events.single;
      expect(event, isA<HomeLocationDenied>());
      expect((event as HomeLocationDenied).canOpenSettings, isTrue);
      await cubit.close();
    });

    blocTest<HomeCubit, HomeState>(
      'emits [requesting, disabled] when location services are off',
      build: () {
        when(service.ensurePermission())
            .thenAnswer((_) async => const Result<bool>.failure(LocationError('off', servicesDisabled: true)));
        return HomeCubit(service);
      },
      act: (HomeCubit cubit) => cubit.startTracking(),
      expect: () => const <HomeState>[
        HomeState(status: LocationTrackingStatus.requesting),
        HomeState(status: LocationTrackingStatus.disabled),
      ],
    );

    test('emits HomeLocationDisabled when services are off', () async {
      when(service.ensurePermission())
          .thenAnswer((_) async => const Result<bool>.failure(LocationError('off', servicesDisabled: true)));
      final HomeCubit cubit = HomeCubit(service);

      final List<HomePresentationEvent> events = await capturePresentation(cubit, cubit.startTracking);

      expect(events.single, isA<HomeLocationDisabled>());
      await cubit.close();
    });
  });

  group('stopFollowing', () {
    blocTest<HomeCubit, HomeState>(
      'turns following off',
      build: () => HomeCubit(service),
      act: (HomeCubit cubit) => cubit.stopFollowing(),
      expect: () => const <HomeState>[HomeState(isFollowing: false)],
    );

    blocTest<HomeCubit, HomeState>(
      'is a no-op when already not following',
      build: () => HomeCubit(service),
      seed: () => const HomeState(isFollowing: false),
      act: (HomeCubit cubit) => cubit.stopFollowing(),
      expect: () => const <HomeState>[],
    );
  });

  group('recenter', () {
    test('does nothing without a location', () async {
      final HomeCubit cubit = HomeCubit(service);
      final List<HomeState> states = <HomeState>[];
      final StreamSubscription<HomeState> sub = cubit.stream.listen(states.add);

      final List<HomePresentationEvent> events = await capturePresentation(cubit, () async => cubit.recenter());

      expect(states, isEmpty);
      expect(events, isEmpty);
      await sub.cancel();
      await cubit.close();
    });

    test('re-enables following and requests a recenter when a location exists', () async {
      // Drive a location into the state via the public API, then pan away.
      final StreamController<UserLocation> fixes = StreamController<UserLocation>();
      when(service.ensurePermission()).thenAnswer((_) async => const Result<bool>.success(true));
      when(service.positionStream(distanceFilterMeters: anyNamed('distanceFilterMeters')))
          .thenAnswer((_) => fixes.stream);
      final HomeCubit cubit = HomeCubit(service);
      await cubit.startTracking();
      fixes.add(_fix());
      await Future<void>.delayed(const Duration(milliseconds: 10));
      cubit.stopFollowing();

      final List<HomePresentationEvent> events = await capturePresentation(cubit, () async => cubit.recenter());

      expect(cubit.state.isFollowing, isTrue);
      expect(events.single, isA<RecenterRequested>());
      await fixes.close();
      await cubit.close();
    });
  });
}
