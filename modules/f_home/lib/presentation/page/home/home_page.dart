import 'package:core/core.dart';
import 'package:d_directions/d_directions.dart';
import 'package:d_location/d_location.dart';
import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:f_home/presentation/page/home/cubit/home_cubit.dart';
import 'package:f_home/presentation/page/home/cubit/home_presentation_event.dart';
import 'package:f_home/presentation/page/home/cubit/home_state.dart';
import 'package:f_home/presentation/page/home/home_map_controls.dart';
import 'package:f_home/presentation/page/home/widgets/locating_indicator.dart';
import 'package:f_home/presentation/page/home/widgets/route_chips.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class HomePage extends HookWidget {
  const HomePage({super.key});

  // Hardcoded test destination (Katowice centre) for route drawing.
  static const GeoPoint _testDestination = GeoPoint(50.2599, 19.0216);

  @override
  Widget build(BuildContext context) {
    final HomeCubit cubit = useBloc<HomeCubit>();
    final HomeState state = useBlocBuilder(cubit);
    final Strings strings = Strings.of(context);

    final ValueNotifier<MapboxMap?> map = useState<MapboxMap?>(null);
    final ObjectRef<bool> pendingRecenter = useRef<bool>(false);
    final ObjectRef<PolylineAnnotationManager?> routeManager = useRef<PolylineAnnotationManager?>(null);

    final CameraOptions initialCamera = useMemoized(
      () => CameraOptions(
        center: Point(coordinates: Position(18.9985, 50.1357)),
        zoom: 11,
      ),
      const <Object?>[],
    );

    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final double margin = context.spacing.m;

    final bool isLocating = state.location == null &&
        (state.status == LocationTrackingStatus.requesting || state.status == LocationTrackingStatus.tracking);

    void locate(UserLocation location) {
      final MapboxMap? controller = map.value;
      if (controller == null) {
        pendingRecenter.value = true;
        return;
      }
      pendingRecenter.value = false;
      controller.locateOn(location);
    }

    Future<void> renderRoutes() async {
      final MapboxMap? controller = map.value;
      if (controller == null) return;
      if (state.routes.isEmpty) {
        await routeManager.value?.deleteAll();
        return;
      }
      routeManager.value ??= await controller.annotations.createPolylineAnnotationManager();
      await routeManager.value!.drawRoutes(state.routes, state.selectedRouteIndex);
    }

    void _listener(HomePresentationEvent event) {
      switch (event) {
        case RecenterRequested():
          final UserLocation? location = cubit.state.location;
          if (location != null) locate(location);
        case HomeRouteFailed():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.f_home_route_failed)),
          );
        case HomeLocationDisabled():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.f_home_location_disabled)),
          );
        case HomeLocationDenied(:final bool canOpenSettings):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.f_home_location_denied),
              action: canOpenSettings
                  ? SnackBarAction(label: strings.app_open_settings, onPressed: cubit.openSettings)
                  : null,
            ),
          );
      }
    }

    useOnStreamChange<HomePresentationEvent>(cubit.presentation, onData: _listener);

    useEffect(
      () {
        cubit.startTracking();
        return null;
      },
      const <Object?>[],
    );

    // Lay out ornaments once the map is ready and whenever the inset changes.
    useEffect(
      () {
        map.value?.applyHomeOrnaments(bottomInset: bottomInset, margin: margin);
        return null;
      },
      <Object?>[map.value, bottomInset, margin],
    );

    // Honor a recenter that was requested before the map became ready.
    useEffect(
      () {
        final MapboxMap? controller = map.value;
        final UserLocation? location = state.location;
        if (controller != null && location != null && pendingRecenter.value) {
          pendingRecenter.value = false;
          controller.locateOn(location);
        }
        return null;
      },
      <Object?>[map.value],
    );

    // Pan to each new fix while following (zoom is handled by RecenterRequested).
    useEffect(
      () {
        final UserLocation? location = state.location;
        if (map.value != null && location != null && state.isFollowing) {
          map.value!.panTo(location);
        }
        return null;
      },
      <Object?>[state.location, map.value],
    );

    useEffect(
      () {
        renderRoutes();
        return null;
      },
      <Object?>[state.routes, state.selectedRouteIndex, map.value],
    );

    final List<String> routeLabels = <String>[
      for (final MapRoute route in state.routes)
        strings.f_home_route_summary(
          (route.durationSeconds / 60).round(),
          (route.distanceMeters / 1000).toStringAsFixed(1),
        ),
    ];

    return Scaffold(
      floatingActionButton: state.location == null
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton.small(
                  heroTag: 'route',
                  onPressed: () => cubit.requestRoute(_testDestination),
                  child: const Icon(Icons.directions),
                ),
                SizedBox(height: context.spacing.s),
                FloatingActionButton(
                  heroTag: 'recenter',
                  tooltip: strings.f_home_recenter,
                  onPressed: cubit.recenter,
                  child: Icon(state.isFollowing ? Icons.my_location : Icons.location_searching),
                ),
              ],
            ),
      body: Stack(
        children: <Widget>[
          MapWidget(
            styleUri: MapboxConfig.styleUri,
            // ignore: deprecated_member_use
            cameraOptions: initialCamera,
            onMapCreated: (MapboxMap mapboxMap) {
              mapboxMap.enableLocationPuck();
              map.value = mapboxMap;
            },
            onScrollListener: (MapContentGestureContext _) => cubit.stopFollowing(),
            // ignore: deprecated_member_use
            onLongTapListener: (MapContentGestureContext context) {
              final Position position = context.point.coordinates;
              cubit.addWaypoint(GeoPoint(position.lat.toDouble(), position.lng.toDouble()));
            },
          ),
          if (isLocating) LocatingIndicator(label: strings.f_home_locating),
          if (routeLabels.isNotEmpty)
            RouteChips(
              labels: routeLabels,
              selectedIndex: state.selectedRouteIndex,
              onSelected: cubit.selectRoute,
            ),
        ],
      ),
    );
  }
}
