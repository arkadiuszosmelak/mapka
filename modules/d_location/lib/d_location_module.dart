import 'package:core/core.dart';
import 'package:d_location/dependency_injection/d_location_package_module.module.dart';

class DLocationModule extends ModuleManifest {
  const DLocationModule();

  @override
  MicroPackageModule? get dependencyInjectionModule => DLocationPackageModule();
}
