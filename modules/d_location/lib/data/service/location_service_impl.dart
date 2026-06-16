import 'package:core/core.dart';
import 'package:d_location/data/mapper/position_mapper.dart';
import 'package:d_location/domain/model/user_location.dart';
import 'package:d_location/domain/service/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: LocationService)
class LocationServiceImpl implements LocationService {
  const LocationServiceImpl();

  @override
  Future<Result<bool>> ensurePermission() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Result<bool>.failure(
          LocationError('Location services are disabled.', servicesDisabled: true),
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        return const Result<bool>.failure(
          LocationError('Location permission permanently denied.', permanentlyDenied: true),
        );
      }
      if (permission == LocationPermission.denied) {
        return const Result<bool>.failure(LocationError('Location permission denied.'));
      }

      return const Result<bool>.success(true);
    } catch (error, stackTrace) {
      return Result<bool>.failure(
        LocationError('Failed to resolve location permission.', cause: error, stackTrace: stackTrace),
      );
    }
  }

  @override
  Future<UserLocation?> lastKnownLocation() async {
    try {
      final Position? position = await Geolocator.getLastKnownPosition();
      return position?.toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserLocation> positionStream({double distanceFilterMeters = 5}) {
    final LocationSettings settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: distanceFilterMeters.round(),
    );
    return Geolocator.getPositionStream(locationSettings: settings).map((Position position) => position.toDomain());
  }

  @override
  Future<void> openSettings() => Geolocator.openAppSettings();
}
