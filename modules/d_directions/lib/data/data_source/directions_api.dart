import 'package:d_directions/data/model/directions_response_dto.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'directions_api.g.dart';

@RestApi()
abstract class DirectionsApi {
  factory DirectionsApi(Dio dio, {String baseUrl}) = _DirectionsApi;

  /// [coordinates] is `lng,lat;lng,lat[;...]` (raw — `,`/`;` are path-legal).
  /// `driving-traffic` is traffic-aware but capped at 3 coordinates; Mapbox only
  /// returns alternatives when there are exactly two (no intermediate waypoints).
  @GET('/directions/v5/mapbox/driving-traffic/{coordinates}')
  Future<DirectionsResponseDto> getDrivingRoute(
    @Path('coordinates') String coordinates, {
    @Query('access_token') required String accessToken,
    @Query('alternatives') required bool alternatives,
    @Query('geometries') String geometries = 'geojson',
    @Query('overview') String overview = 'full',
  });
}
