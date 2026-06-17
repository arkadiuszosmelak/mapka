import 'package:core/core.dart';
import 'package:d_directions/domain/model/geo_point.dart';
import 'package:d_directions/domain/model/map_route.dart';

abstract interface class DirectionsService {
  Future<Result<List<MapRoute>>> fetchRoutes({
    required GeoPoint origin,
    required GeoPoint destination,
    List<GeoPoint> waypoints = const <GeoPoint>[],
  });
}
