import 'package:core/core.dart';
import 'package:f_onboarding/dependency_injection/onboarding_package_module.module.dart';

/// What the onboarding module contributes to the app shell.
///
/// Routes are contributed separately via `getOnboardingSubtree(...)` because
/// they need navigation callbacks the manifest cannot know about.
class OnboardingModule extends ModuleManifest {
  const OnboardingModule();

  @override
  MicroPackageModule? get dependencyInjectionModule => FOnboardingPackageModule();
}
