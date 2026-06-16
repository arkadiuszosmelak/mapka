import 'package:d_location/d_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
