import 'package:d_location/d_location.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Camera + ornament helpers for the home map, keeping `HomePage` thin.
extension HomeMapControls on MapboxMap {
  /// Fixed on purpose: deriving zoom from `cameraForCoordinateBounds` reads the
  /// view size, unreliable right after creation (buffer starts at 64x64) and
  /// intermittently snapped the camera out to the globe.
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
