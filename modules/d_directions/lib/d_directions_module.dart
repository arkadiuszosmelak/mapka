import 'package:core/core.dart';
import 'package:d_directions/dependency_injection/d_directions_package_module.module.dart';

class DDirectionsModule extends ModuleManifest {
  const DDirectionsModule();

  @override
  MicroPackageModule? get dependencyInjectionModule => DDirectionsPackageModule();
}
