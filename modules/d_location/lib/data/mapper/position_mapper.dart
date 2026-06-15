import 'package:d_location/domain/model/user_location.dart';
import 'package:geolocator/geolocator.dart';

extension PositionMapper on Position {
  UserLocation toDomain() {
    return UserLocation(
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      speed: speed,
      heading: (heading.isNaN || heading < 0) ? null : heading,
      timestamp: timestamp,
    );
  }
}
