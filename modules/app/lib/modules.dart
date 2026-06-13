import 'package:core/core.dart';
import 'package:f_onboarding/f_onboarding.dart';

/// Every module the app ships. Add new modules here (and their route subtree
/// in `app_router.dart`). The DI registration and observers are derived from
/// this list automatically.
const List<ModuleManifest> appModules = <ModuleManifest>[
  OnboardingModule(),
];
