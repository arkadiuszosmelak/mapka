import 'package:d_directions/d_directions.dart';
import 'package:d_directions/data/mapper/directions_mapper.dart';
import 'package:d_directions/data/model/directions_response_dto.dart';
import 'package:flutter_test/flutter_test.dart';

DirectionsResponseDto _response(List<RouteDto> routes) => DirectionsResponseDto(routes: routes);

RouteDto _route(List<List<num>> coordinates, {double distance = 100, double duration = 60}) {
  return RouteDto(distance: distance, duration: duration, geometry: GeometryDto(coordinates: coordinates));
}

void main() {
  group('DirectionsResponseMapper.toDomain', () {
    test('swaps GeoJSON [lng, lat] into domain (lat, lng)', () {
      final List<MapRoute> routes = _response(<RouteDto>[
        _route(<List<num>>[
          <num>[19.0216, 50.2599],
          <num>[17.0385, 51.1079],
        ]),
      ]).toDomain();

      expect(routes.single.points, <GeoPoint>[
        const GeoPoint(50.2599, 19.0216),
        const GeoPoint(51.1079, 17.0385),
      ]);
    });

    test('maps distance and duration', () {
      final List<MapRoute> routes = _response(<RouteDto>[
        _route(<List<num>>[<num>[0, 0]], distance: 1234.5, duration: 678.9),
      ]).toDomain();

      expect(routes.single.distanceMeters, 1234.5);
      expect(routes.single.durationSeconds, 678.9);
    });

    test('keeps every route (alternatives)', () {
      final List<MapRoute> routes = _response(<RouteDto>[
        _route(<List<num>>[<num>[0, 0]]),
        _route(<List<num>>[<num>[1, 1]]),
        _route(<List<num>>[<num>[2, 2]]),
      ]).toDomain();

      expect(routes, hasLength(3));
    });

    test('handles integer coordinates from JSON (num -> double)', () {
      final List<MapRoute> routes = _response(<RouteDto>[
        _route(<List<num>>[<num>[19, 50]]),
      ]).toDomain();

      expect(routes.single.points.single, const GeoPoint(50, 19));
    });

    test('returns empty when there are no routes', () {
      expect(_response(const <RouteDto>[]).toDomain(), isEmpty);
    });
  });
}
