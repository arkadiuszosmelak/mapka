import 'package:d_directions/domain/model/geo_point.dart';
import 'package:equatable/equatable.dart';

class MapRoute extends Equatable {
  const MapRoute({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  final List<GeoPoint> points;
  final double distanceMeters;
  final double durationSeconds;

  @override
  List<Object?> get props => <Object?>[points, distanceMeters, durationSeconds];
}
