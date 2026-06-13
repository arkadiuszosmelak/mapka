import 'package:app/di/injection.config.dart';
import 'package:core/core.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

/// The app-wide service locator.
final GetIt getIt = GetIt.instance;

/// Builds the dependency graph by aggregating every module's micro-package
/// DI module into a single [GetIt], `core` first so its services are available
/// to features.
///
/// `@InjectableInit` generates `getIt.init()` for the app's own injectables.
/// The active [AppFlavor] is registered first so any service can depend on it.
@InjectableInit()
Future<void> configureDependencies({
  required AppFlavor flavor,
  required List<ModuleManifest> modules,
}) async {
  getIt.registerSingleton<AppFlavor>(flavor);
  getIt.init();
  final GetItHelper helper = GetItHelper(getIt);
  await CorePackageModule().init(helper);
  for (final ModuleManifest module in modules) {
    await module.dependencyInjectionModule?.init(helper);
  }
}
