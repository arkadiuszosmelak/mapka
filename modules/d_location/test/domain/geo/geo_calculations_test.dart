import 'package:d_location/d_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('boxAround', () {
    test('centers the box on the given point', () {
      final GeoBox box = boxAround(51.1079, 17.0385, 5000);

      expect((box.minLatitude + box.maxLatitude) / 2, closeTo(51.1079, 1e-9));
      expect((box.minLongitude + box.maxLongitude) / 2, closeTo(17.0385, 1e-9));
    });

    test('is symmetric around the center', () {
      const double lat = 51.1079;
      const double lng = 17.0385;
      final GeoBox box = boxAround(lat, lng, 4000);

      expect(box.maxLatitude - lat, closeTo(lat - box.minLatitude, 1e-12));
      expect(box.maxLongitude - lng, closeTo(lng - box.minLongitude, 1e-12));
    });

    test('latitude and longitude deltas are equal at the equator', () {
      final GeoBox box = boxAround(0, 0, 1000);

      final double latDelta = box.maxLatitude;
      final double lngDelta = box.maxLongitude;
      expect(lngDelta, closeTo(latDelta, 1e-12));
      // halfSpan / metersPerLatDegree = 500 / 111320.
      expect(latDelta, closeTo(500 / 111320, 1e-9));
    });

    test('longitude delta grows with latitude (scaled by 1/cos)', () {
      final GeoBox equator = boxAround(0, 0, 1000);
      final GeoBox north = boxAround(60, 0, 1000);

      // cos(60°) = 0.5, so the longitude delta roughly doubles.
      final double equatorLngDelta = equator.maxLongitude;
      final double northLngDelta = north.maxLongitude;
      expect(northLngDelta, closeTo(equatorLngDelta * 2, 1e-6));
      // Latitude delta is independent of latitude (compare deltas, not absolute
      // coordinates: the northern box is centered on 60°).
      expect(north.maxLatitude - 60, closeTo(equator.maxLatitude, 1e-12));
    });
  });

  group('distanceMeters', () {
    test('is zero for the same point', () {
      expect(distanceMeters(51.1079, 17.0385, 51.1079, 17.0385), closeTo(0, 1e-6));
    });

    test('one degree of longitude at the equator is ~111.2 km', () {
      expect(distanceMeters(0, 0, 0, 1), closeTo(111195, 5));
    });

    test('one degree of latitude is ~111.2 km', () {
      expect(distanceMeters(0, 0, 1, 0), closeTo(111195, 5));
    });

    test('is symmetric', () {
      final double ab = distanceMeters(51.1079, 17.0385, 52.2297, 21.0122);
      final double ba = distanceMeters(52.2297, 21.0122, 51.1079, 17.0385);
      expect(ab, closeTo(ba, 1e-6));
    });

    test('Wrocław to Warsaw is roughly 300 km', () {
      final double distance = distanceMeters(51.1079, 17.0385, 52.2297, 21.0122);
      expect(distance, closeTo(301000, 5000));
    });
  });
}
