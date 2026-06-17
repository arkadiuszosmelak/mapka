import 'package:core/core.dart';
import 'package:d_directions/data/data_source/directions_api.dart';
import 'package:d_directions/data/mapper/directions_mapper.dart';
import 'package:d_directions/data/model/directions_response_dto.dart';
import 'package:d_directions/domain/model/geo_point.dart';
import 'package:d_directions/domain/model/map_route.dart';
import 'package:d_directions/domain/service/directions_service.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: DirectionsService)
class DirectionsServiceImpl implements DirectionsService {
  const DirectionsServiceImpl(this._api);

  final DirectionsApi _api;

  @override
  Future<Result<List<MapRoute>>> fetchRoutes({
    required GeoPoint origin,
    required GeoPoint destination,
    List<GeoPoint> waypoints = const <GeoPoint>[],
  }) async {
    // driving-traffic allows at most 3 coordinates (origin + 1 waypoint + dest).
    assert(waypoints.length <= 1, 'driving-traffic supports at most one waypoint');

    if (!MapboxConfig.hasToken) {
      return const Result<List<MapRoute>>.failure(NetworkError('Missing Mapbox access token.'));
    }

    final String coordinates = <GeoPoint>[origin, ...waypoints, destination]
        .map((GeoPoint p) => '${p.longitude},${p.latitude}')
        .join(';');

    try {
      final DirectionsResponseDto response = await _api.getDrivingRoute(
        coordinates,
        accessToken: MapboxConfig.accessToken,
        // Alternatives are only returned for a plain start→end request.
        alternatives: waypoints.isEmpty,
      );
      final List<MapRoute> routes = response.toDomain();
      if (routes.isEmpty) {
        return const Result<List<MapRoute>>.failure(NetworkError('No route found.'));
      }
      return Result<List<MapRoute>>.success(routes);
    } on DioException catch (error, stackTrace) {
      return Result<List<MapRoute>>.failure(
        ConnectionError('Failed to fetch the route.', cause: error, stackTrace: stackTrace),
      );
    } catch (error, stackTrace) {
      return Result<List<MapRoute>>.failure(
        UnknownError('Unexpected routing error.', cause: error, stackTrace: stackTrace),
      );
    }
  }
}
