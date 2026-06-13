import 'package:injectable/injectable.dart';

/// Triggers generation of `CorePackageModule` (a `MicroPackageModule`) covering
/// every `@injectable` in this package. The app aggregates it into its `GetIt`.
///
/// Run `melos gen` to (re)generate `core_package_module.module.dart`.
@InjectableInit.microPackage()
void initCorePackage() {}
