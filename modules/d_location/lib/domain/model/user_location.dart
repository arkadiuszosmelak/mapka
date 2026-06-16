import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.timestamp,
  });

  final double latitude;
  final double longitude;

  /// Horizontal accuracy, in meters.
  final double accuracy;

  /// Ground speed, in meters per second.
  final double speed;

  /// Degrees clockwise from true north (0–360), or `null` when unavailable.
  final double? heading;

  final DateTime timestamp;

  @override
  List<Object?> get props => <Object?>[latitude, longitude, accuracy, speed, heading, timestamp];
}
