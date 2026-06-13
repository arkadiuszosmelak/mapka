import 'package:core/core.dart';
import 'package:f_onboarding/presentation/page/onboarding/onboarding_page.dart';
import 'package:f_onboarding/presentation/page/onboarding_permissions/onboarding_permissions_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart' hide NavigationCallback;

/// Named routes owned by the onboarding module. Never hardcode these paths
/// elsewhere — navigate by `name`.
abstract final class OnboardingRoutes {
  static const RouteDefinition intro = RouteDefinition(
    path: '/onboarding',
    name: 'onboarding',
  );
  static const RouteDefinition permissions = RouteDefinition(
    path: '/onboarding/permissions',
    name: 'onboarding_permissions',
  );
}

/// Builds the onboarding route subtree. The app composes this into the root
/// router and supplies [onCompleted] (where to go once onboarding finishes).
///
/// Intra-module navigation (intro -> permissions) is bound here in the builder,
/// so the pages stay free of route knowledge.
List<RouteBase> getOnboardingSubtree({required NavigationCallback onCompleted}) {
  return <RouteBase>[
    GoRoute(
      path: OnboardingRoutes.intro.path,
      name: OnboardingRoutes.intro.name,
      builder: (BuildContext context, GoRouterState state) => OnboardingPage(
        onGetStarted: (BuildContext ctx) => ctx.goNamed(OnboardingRoutes.permissions.name),
      ),
    ),
    GoRoute(
      path: OnboardingRoutes.permissions.path,
      name: OnboardingRoutes.permissions.name,
      builder: (BuildContext context, GoRouterState state) => OnboardingPermissionsPage(
        onCompleted: onCompleted,
      ),
    ),
  ];
}
