import 'package:d_directions/data/data_source/directions_api.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@module
abstract class DirectionsNetworkModule {
  @lazySingleton
  DirectionsApi directionsApi() => DirectionsApi(Dio(BaseOptions(baseUrl: 'https://api.mapbox.com')));
}
