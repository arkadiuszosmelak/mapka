import 'dart:async';

import 'package:core/core.dart';
import 'package:d_location/d_location.dart';
import 'package:f_home/presentation/page/home/cubit/home_presentation_event.dart';
import 'package:f_home/presentation/page/home/cubit/home_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState, HomePresentationEvent> {
  HomeCubit(this._locationService) : super(const HomeState());

  final LocationService _locationService;
  StreamSubscription<UserLocation>? _subscription;
  bool _firstFix = true;

  Future<void> startTracking() async {
    if (state.status == LocationTrackingStatus.tracking) return;

    emit(state.copyWith(status: LocationTrackingStatus.requesting));
    final Result<bool> permission = await _locationService.ensurePermission();

    switch (permission) {
      case Success<bool>():
        await _beginTracking();
      case Failure<bool>(:final AppError error):
        _onPermissionFailure(error);
    }
  }

  Future<void> _beginTracking() async {
    emit(state.copyWith(status: LocationTrackingStatus.tracking));
    // Instant, cached fix to cut the perceived wait; refined by the stream.
    final UserLocation? lastKnown = await _locationService.lastKnownLocation();
    if (lastKnown != null && state.location == null) {
      _onFix(lastKnown);
    }
    _subscribe();
  }

  void _subscribe() {
    _subscription?.cancel();
    _subscription = _locationService.positionStream().listen(_onFix);
  }

  void _onFix(UserLocation location) {
    emit(state.copyWith(location: location));
    if (_firstFix) {
      _firstFix = false;
      if (state.isFollowing) emitPresentation(const RecenterRequested());
    }
  }

  void stopFollowing() {
    if (state.isFollowing) emit(state.copyWith(isFollowing: false));
  }

  /// One-shot [RecenterRequested] so the view acts even when already following.
  void recenter() {
    if (state.location == null) return;
    if (!state.isFollowing) emit(state.copyWith(isFollowing: true));
    emitPresentation(const RecenterRequested());
  }

  void _onPermissionFailure(AppError error) {
    if (error is LocationError && error.servicesDisabled) {
      emit(state.copyWith(status: LocationTrackingStatus.disabled));
      emitPresentation(const HomeLocationDisabled());
      return;
    }
    emit(state.copyWith(status: LocationTrackingStatus.denied));
    emitPresentation(
      HomeLocationDenied(canOpenSettings: error is LocationError && error.permanentlyDenied),
    );
  }

  Future<void> openSettings() => _locationService.openSettings();

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
