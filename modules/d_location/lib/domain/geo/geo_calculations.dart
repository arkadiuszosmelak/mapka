import 'dart:math' as math;

const double _earthRadiusMeters = 6371000;

/// Great-circle distance in meters (haversine).
double distanceMeters(double latitude1, double longitude1, double latitude2, double longitude2) {
  final double dLat = _radians(latitude2 - latitude1);
  final double dLng = _radians(longitude2 - longitude1);
  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_radians(latitude1)) * math.cos(_radians(latitude2)) * math.sin(dLng / 2) * math.sin(dLng / 2);
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  return _earthRadiusMeters * c;
}

double _radians(double degrees) => degrees * math.pi / 180;
