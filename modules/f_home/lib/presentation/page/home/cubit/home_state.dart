import 'package:d_directions/d_directions.dart';
import 'package:d_location/d_location.dart';
import 'package:equatable/equatable.dart';

enum LocationTrackingStatus { initial, requesting, tracking, denied, disabled }

class HomeState extends Equatable {
  const HomeState({
    this.status = LocationTrackingStatus.initial,
    this.location,
    this.isFollowing = true,
    this.destination,
    this.waypoint,
    this.routes = const <MapRoute>[],
    this.selectedRouteIndex = 0,
  });

  final LocationTrackingStatus status;
  final UserLocation? location;

  final bool isFollowing;

  final GeoPoint? destination;
  final GeoPoint? waypoint;
  final List<MapRoute> routes;
  final int selectedRouteIndex;

  MapRoute? get selectedRoute =>
      selectedRouteIndex >= 0 && selectedRouteIndex < routes.length ? routes[selectedRouteIndex] : null;

  HomeState copyWith({
    LocationTrackingStatus? status,
    UserLocation? location,
    bool? isFollowing,
    GeoPoint? destination,
    GeoPoint? waypoint,
    bool clearWaypoint = false,
    List<MapRoute>? routes,
    int? selectedRouteIndex,
  }) {
    return HomeState(
      status: status ?? this.status,
      location: location ?? this.location,
      isFollowing: isFollowing ?? this.isFollowing,
      destination: destination ?? this.destination,
      waypoint: clearWaypoint ? null : (waypoint ?? this.waypoint),
      routes: routes ?? this.routes,
      selectedRouteIndex: selectedRouteIndex ?? this.selectedRouteIndex,
    );
  }

  @override
  List<Object?> get props =>
      <Object?>[status, location, isFollowing, destination, waypoint, routes, selectedRouteIndex];
}
