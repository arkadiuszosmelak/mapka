import 'package:d_directions/d_directions.dart';
import 'package:d_location/d_location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

extension HomeMapControls on MapboxMap {
  static const double _locateZoom = 15;

  static const int _animationMs = 800;

  // Standard FloatingActionButton metrics, to park the compass above the FAB.
  static const double _fabSize = 56;
  static const double _fabEdgeMargin = 16;
  static const double _compassSize = 38;

  Future<void> applyHomeOrnaments({required double bottomInset, required double margin}) async {
    await scaleBar.updateSettings(ScaleBarSettings(enabled: false));
    await compass.updateSettings(
      CompassSettings(
        position: OrnamentPosition.BOTTOM_RIGHT,
        marginRight: _fabEdgeMargin + (_fabSize - _compassSize) / 2,
        marginBottom: bottomInset + _fabEdgeMargin + _fabSize + margin,
      ),
    );
    await logo.updateSettings(LogoSettings(marginBottom: bottomInset, marginLeft: margin));
    await attribution.updateSettings(
      AttributionSettings(
        position: OrnamentPosition.BOTTOM_RIGHT,
        marginBottom: bottomInset,
        marginRight: margin,
      ),
    );
  }

  Future<void> enableLocationPuck() {
    return location.updateSettings(
      LocationComponentSettings(enabled: true, pulsingEnabled: true, puckBearingEnabled: true),
    );
  }

  /// Pans to [location], keeping the current zoom.
  Future<void> panTo(UserLocation location) {
    return easeTo(
      CameraOptions(center: Point(coordinates: Position(location.longitude, location.latitude))),
      MapAnimationOptions(duration: _animationMs),
    );
  }

  Future<void> locateOn(UserLocation location) {
    return easeTo(
      CameraOptions(
        center: Point(coordinates: Position(location.longitude, location.latitude)),
        zoom: _locateZoom,
      ),
      MapAnimationOptions(duration: _animationMs),
    );
  }
}

extension RoutePolyline on PolylineAnnotationManager {
  static const int _selectedColor = 0xFF1E88E5;
  static const int _alternativeColor = 0xFF9E9E9E;
  static const double _selectedWidth = 7;
  static const double _alternativeWidth = 5;

  /// Redraws all [routes]: alternatives in grey underneath, the selected one in
  /// thick blue on top.
  Future<void> drawRoutes(List<MapRoute> routes, int selectedIndex) async {
    await deleteAll();
    for (int i = 0; i < routes.length; i++) {
      if (i != selectedIndex) {
        await create(_routeOptions(routes[i], selected: false));
      }
    }
    if (selectedIndex >= 0 && selectedIndex < routes.length) {
      await create(_routeOptions(routes[selectedIndex], selected: true));
    }
  }

  PolylineAnnotationOptions _routeOptions(MapRoute route, {required bool selected}) {
    return PolylineAnnotationOptions(
      geometry: LineString(
        coordinates: route.points.map((GeoPoint p) => Position(p.longitude, p.latitude)).toList(),
      ),
      lineColor: selected ? _selectedColor : _alternativeColor,
      lineWidth: selected ? _selectedWidth : _alternativeWidth,
    );
  }
}
