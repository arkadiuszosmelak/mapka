/// Onboarding feature module.
///
/// Public surface used by the app:
/// - [OnboardingModule] — the module manifest (DI / guards / observers).
/// - [getOnboardingSubtree] — the route subtree.
///
/// Strings live in `d_translations` (the single translations module).
library;

export 'domain/service/onboarding_service.dart' show OnboardingService;
export 'f_onboarding_module.dart';
export 'routing/onboarding_routes.dart';
