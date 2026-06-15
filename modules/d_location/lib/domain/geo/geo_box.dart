import 'package:equatable/equatable.dart';

class GeoBox extends Equatable {
  const GeoBox({
    required this.minLatitude,
    required this.minLongitude,
    required this.maxLatitude,
    required this.maxLongitude,
  });

  final double minLatitude;
  final double minLongitude;
  final double maxLatitude;
  final double maxLongitude;

  @override
  List<Object?> get props => <Object?>[minLatitude, minLongitude, maxLatitude, maxLongitude];
}
