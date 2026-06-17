import 'package:d_directions/data/model/directions_response_dto.dart';
import 'package:d_directions/domain/model/geo_point.dart';
import 'package:d_directions/domain/model/map_route.dart';

extension DirectionsResponseMapper on DirectionsResponseDto {
  List<MapRoute> toDomain() => routes.map((RouteDto route) {
        final List<GeoPoint> points =
            route.geometry.coordinates.map((List<num> c) => GeoPoint(c[1].toDouble(), c[0].toDouble())).toList();
        return MapRoute(points: points, distanceMeters: route.distance, durationSeconds: route.duration);
      }).toList();
}
