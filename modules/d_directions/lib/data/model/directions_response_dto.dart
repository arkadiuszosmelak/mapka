import 'package:json_annotation/json_annotation.dart';

part 'directions_response_dto.g.dart';

@JsonSerializable(createToJson: false)
class DirectionsResponseDto {
  const DirectionsResponseDto({required this.routes});

  factory DirectionsResponseDto.fromJson(Map<String, dynamic> json) => _$DirectionsResponseDtoFromJson(json);

  final List<RouteDto> routes;
}

@JsonSerializable(createToJson: false)
class RouteDto {
  const RouteDto({required this.distance, required this.duration, required this.geometry});

  factory RouteDto.fromJson(Map<String, dynamic> json) => _$RouteDtoFromJson(json);

  final double distance;
  final double duration;
  final GeometryDto geometry;
}

@JsonSerializable(createToJson: false)
class GeometryDto {
  const GeometryDto({required this.coordinates});

  factory GeometryDto.fromJson(Map<String, dynamic> json) => _$GeometryDtoFromJson(json);

  final List<List<num>> coordinates;
}
