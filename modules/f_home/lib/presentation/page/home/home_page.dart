import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ObjectRef<MapboxMap?> mapRef = useRef<MapboxMap?>(null);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double margin = context.spacing.m;

    void applyOrnaments() {
      final MapboxMap? map = mapRef.value;
      if (map == null) return;

      map.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
      map.logo.updateSettings(
        LogoSettings(marginBottom: bottomInset, marginLeft: margin),
      );
      map.attribution.updateSettings(
        AttributionSettings(
          position: OrnamentPosition.BOTTOM_RIGHT,
          marginBottom: bottomInset,
          marginRight: margin,
        ),
      );
    }

    useEffect(
      () {
        applyOrnaments();
        return null;
      },
      <Object>[bottomInset, margin],
    );

    return Scaffold(
      body: MapWidget(
        styleUri: MapboxConfig.styleUri,
        viewport: CameraViewportState(
          center: Point(coordinates: Position(17.0385, 51.1079)),
          zoom: 11,
        ),
        onMapCreated: (MapboxMap mapboxMap) {
          mapRef.value = mapboxMap;
          applyOrnaments();
        },
      ),
    );
  }
}
