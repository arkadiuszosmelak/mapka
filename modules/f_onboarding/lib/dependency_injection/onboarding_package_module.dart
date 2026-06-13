import 'package:injectable/injectable.dart';

/// Triggers generation of the micro-package DI module (`FOnboardingPackageModule`)
/// covering every `@injectable` in this module. Run `melos gen`.
@InjectableInit.microPackage()
void initOnboardingPackage() {}
