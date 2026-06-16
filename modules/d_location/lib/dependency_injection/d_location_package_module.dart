import 'package:injectable/injectable.dart';

/// Triggers generation of the micro-package DI module (`DLocationPackageModule`)
/// covering every `@injectable` in this module. Run `melos gen`.
@InjectableInit.microPackage()
void initDLocationPackage() {}
