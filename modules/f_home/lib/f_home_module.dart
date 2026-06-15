import 'package:core/core.dart';
import 'package:f_home/dependency_injection/home_package_module.module.dart';

/// What the home module contributes to the app shell: its DI registration
/// (the map screen's `HomeCubit`).
class HomeModule extends ModuleManifest {
  const HomeModule();

  @override
  MicroPackageModule? get dependencyInjectionModule => FHomePackageModule();
}
