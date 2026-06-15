import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: MapWidget(
        styleUri: MapboxConfig.styleUri,
        viewport: CameraViewportState(
          center: Point(coordinates: Position(17.0385, 51.1079)),
          zoom: 11,
        ),
        onMapCreated: (MapboxMap mapboxMap) {
          mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false));
          mapboxMap.logo.updateSettings(LogoSettings(marginBottom: bottomInset, marginLeft: context.spacing.m));
          mapboxMap.attribution.updateSettings(AttributionSettings(marginBottom: bottomInset, marginLeft: 100));
        },
      ),
    );
  }
}
