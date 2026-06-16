import 'package:injectable/injectable.dart';

/// Triggers generation of the micro-package DI module (`FHomePackageModule`)
/// covering every `@injectable` in this module. Run `melos gen`.
@InjectableInit.microPackage()
void initHomePackage() {}
