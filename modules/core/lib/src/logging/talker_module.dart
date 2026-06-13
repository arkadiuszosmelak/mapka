import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Provides the shared [Talker] instance to DI. Network (Dio) and Bloc loggers
/// are attached to this same instance so all logs land in one place.
@module
abstract class TalkerModule {
  @lazySingleton
  Talker get talker => TalkerFlutter.init();
}
