import 'package:core/core.dart';

/// What this module contributes to the app shell.
///
/// Once the module declares `@injectable` services, add a micro-package init
/// (`@InjectableInit.microPackage()`), run `melos gen`, and return the
/// generated `*PackageModule` from [dependencyInjectionModule].
class ModuleTemplateModule extends ModuleManifest {
  const ModuleTemplateModule();

  @override
  MicroPackageModule? get dependencyInjectionModule => null;
}
