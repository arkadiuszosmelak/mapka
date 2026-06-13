import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provides app-wide key-value storage. `@preResolve` means the instance is
/// awaited during DI init, so consumers can inject [SharedPreferences]
/// synchronously.
@module
abstract class StorageModule {
  @preResolve
  Future<SharedPreferences> get sharedPreferences => SharedPreferences.getInstance();
}
