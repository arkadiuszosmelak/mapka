import 'dart:async';

import 'package:core/core.dart';
import 'package:d_directions/d_directions.dart';
import 'package:d_location/d_location.dart';
import 'package:f_home/presentation/page/home/cubit/home_presentation_event.dart';
import 'package:f_home/presentation/page/home/cubit/home_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends BaseCubit<HomeState, HomePresentationEvent> {
  HomeCubit(this._locationService, this._directionsService) : super(const HomeState());

  final LocationService _locationService;
  final DirectionsService _directionsService;
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

  /// Routes from the current position to [destination] (with alternatives).
  Future<void> requestRoute(GeoPoint destination) async {
    if (state.location == null) return;
    emit(state.copyWith(destination: destination, clearWaypoint: true));
    await _fetchRoutes(destination, const <GeoPoint>[]);
  }

  /// Re-routes through [waypoint] to the current destination (single route).
  Future<void> addWaypoint(GeoPoint waypoint) async {
    final GeoPoint? destination = state.destination;
    if (destination == null || state.location == null) return;
    emit(state.copyWith(waypoint: waypoint));
    await _fetchRoutes(destination, <GeoPoint>[waypoint]);
  }

  void selectRoute(int index) {
    if (index != state.selectedRouteIndex && index >= 0 && index < state.routes.length) {
      emit(state.copyWith(selectedRouteIndex: index));
    }
  }

  Future<void> _fetchRoutes(GeoPoint destination, List<GeoPoint> waypoints) async {
    final UserLocation? origin = state.location;
    if (origin == null) return;

    final Result<List<MapRoute>> result = await _directionsService.fetchRoutes(
      origin: GeoPoint(origin.latitude, origin.longitude),
      destination: destination,
      waypoints: waypoints,
    );
    result.fold(
      onSuccess: (List<MapRoute> routes) => emit(state.copyWith(routes: routes, selectedRouteIndex: 0)),
      onFailure: (AppError _) => emitPresentation(const HomeRouteFailed()),
    );
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
