import 'dart:async';

import 'package:app/routing/app_routes.dart';
import 'package:core/core.dart';
import 'package:f_onboarding/f_onboarding.dart';
import 'package:go_router/go_router.dart' hide NavigationCallback;
import 'package:injectable/injectable.dart';

/// Skips onboarding once it has been completed: any onboarding route redirects
/// to home.
///
/// Lives in the app because the post-onboarding destination ([AppRoutes.home])
/// is an app-shell concern, while the completion flag comes from the onboarding
/// feature's service.
@injectable
class OnboardingGuard extends RouteGuard {
  const OnboardingGuard(this._onboardingService);

  final OnboardingService _onboardingService;

  @override
  Future<RouteDefinition?> call(GoRouterState state) async {
    final String location = state.matchedLocation;
    final bool isOnboarding = location == OnboardingRoutes.intro.path ||
        location == OnboardingRoutes.permissions.path;
    if (!isOnboarding) {
      return null;
    }

    final bool completed = await _onboardingService.isCompleted();
    return completed ? AppRoutes.home : null;
  }
}
