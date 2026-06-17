import 'package:core/core.dart';
import 'package:d_directions/data/data_source/directions_api.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

@module
abstract class DirectionsNetworkModule {
  @lazySingleton
  DirectionsApi directionsApi(Talker talker) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.mapbox.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    )..interceptors.add(TalkerDioLogger(talker: talker));
    return DirectionsApi(dio);
  }
}
