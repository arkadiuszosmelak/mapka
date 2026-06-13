import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';
import 'package:f_onboarding/domain/service/onboarding_service.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_cubit.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'onboarding_cubit_test.mocks.dart';

@GenerateNiceMocks(<MockSpec<dynamic>>[MockSpec<OnboardingService>()])
void main() {
  late MockOnboardingService service;

  setUpAll(() {
    // Mockito needs a dummy for the custom `Result` return type.
    provideDummy<Result<List<OnboardingStep>>>(
      const Result<List<OnboardingStep>>.failure(UnknownError('dummy')),
    );
  });

  setUp(() {
    service = MockOnboardingService();
  });

  group('OnboardingCubit.load', () {
    const List<OnboardingStep> steps = <OnboardingStep>[
      OnboardingStep(id: 'explore', icon: OnboardingStepIcon.explore),
    ];

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [loading, loaded] with steps when the service succeeds',
      build: () {
        when(service.getSteps()).thenAnswer(
          (_) async => const Result<List<OnboardingStep>>.success(steps),
        );
        return OnboardingCubit(service);
      },
      act: (OnboardingCubit cubit) => cubit.load(),
      expect: () => const <OnboardingState>[
        OnboardingState(status: OnboardingStatus.loading),
        OnboardingState(status: OnboardingStatus.loaded, steps: steps),
      ],
    );

    blocTest<OnboardingCubit, OnboardingState>(
      'emits [loading, error] when the service fails',
      build: () {
        when(service.getSteps()).thenAnswer(
          (_) async => const Result<List<OnboardingStep>>.failure(UnknownError('boom')),
        );
        return OnboardingCubit(service);
      },
      act: (OnboardingCubit cubit) => cubit.load(),
      expect: () => const <OnboardingState>[
        OnboardingState(status: OnboardingStatus.loading),
        OnboardingState(status: OnboardingStatus.error),
      ],
    );
  });

  group('OnboardingCubit.complete', () {
    blocTest<OnboardingCubit, OnboardingState>(
      'marks onboarding completed via the service',
      build: () => OnboardingCubit(service),
      act: (OnboardingCubit cubit) => cubit.complete(),
      verify: (_) => verify(service.markCompleted()).called(1),
    );
  });
}
