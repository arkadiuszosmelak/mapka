import 'dart:math' as math;

import 'package:d_location/domain/geo/geo_box.dart';

const double _earthRadiusMeters = 6371000;
const double _metersPerLatDegree = 111320;

/// Square [GeoBox] of side [spanMeters] around the point. Flat-earth
/// approximation — fine for the few-km spans this is used for.
GeoBox boxAround(double latitude, double longitude, double spanMeters) {
  final double halfSpan = spanMeters / 2;
  final double latDelta = halfSpan / _metersPerLatDegree;
  final double lngDelta = halfSpan / (_metersPerLatDegree * math.cos(_radians(latitude)));
  return GeoBox(
    minLatitude: latitude - latDelta,
    minLongitude: longitude - lngDelta,
    maxLatitude: latitude + latDelta,
    maxLongitude: longitude + lngDelta,
  );
}

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
