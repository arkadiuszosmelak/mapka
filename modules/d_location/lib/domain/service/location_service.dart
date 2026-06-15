import 'package:core/core.dart';
import 'package:d_location/domain/model/user_location.dart';

abstract interface class LocationService {
  /// Requests "when in use" permission; fails with a [LocationError].
  Future<Result<bool>> ensurePermission();

  Future<Result<UserLocation>> currentLocation();

  /// OS-cached position, near-instant; `null` if none is available.
  Future<UserLocation?> lastKnownLocation();

  /// Emits after the device moves at least [distanceFilterMeters].
  Stream<UserLocation> positionStream({double distanceFilterMeters = 5});

  Future<void> openSettings();
}
