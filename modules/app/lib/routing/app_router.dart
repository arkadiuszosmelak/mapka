import 'package:app/modules.dart';
import 'package:app/presentation/error/route_error_page.dart';
import 'package:app/routing/guards/onboarding_guard.dart';
import 'package:core/core.dart';
import 'package:f_home/f_home.dart';
import 'package:f_onboarding/f_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' hide NavigationCallback;
import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Builds and owns the root [GoRouter]. Registered in DI so other layers can
/// navigate via the [rootNavigatorKey] without reaching into widget context.
@lazySingleton
class AppRouter {
  AppRouter(
    this.rootNavigatorKey,
    this._talker,
    this._errorReporter,
    this._onboardingGuard,
  );

  final GlobalKey<NavigatorState> rootNavigatorKey;
  final Talker _talker;
  final ErrorReporter _errorReporter;
  final OnboardingGuard _onboardingGuard;

  late final GoRouter config = _build();

  GoRouter _build() {
    // App-level guards first, then whatever each module contributes.
    final List<RouteGuard> guards = <RouteGuard>[
      _onboardingGuard,
      ...appModules.expand((ModuleManifest m) => m.routeGuards),
    ];
    final List<NavigatorObserver> observers = <NavigatorObserver>[
      TalkerRouteObserver(_talker),
      ...appModules.expand((ModuleManifest m) => m.routeObservers),
    ];

    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      observers: observers,
      errorBuilder: (BuildContext context, GoRouterState state) {
        _errorReporter.silentlyReportError(
          state.error ?? Exception('Unknown routing error: ${state.uri}'),
        );
        return const RouteErrorPage();
      },
      redirect: (BuildContext context, GoRouterState state) async {
        if (state.matchedLocation == '/') {
          return OnboardingRoutes.intro.path;
        }
        for (final RouteGuard guard in guards) {
          try {
            final RouteDefinition? target = await guard(state);
            if (target != null) {
              return target.path;
            }
          } catch (error, stackTrace) {
            // A failing guard must never break navigation — report and skip it.
            _errorReporter.silentlyReportError(error, stackTrace: stackTrace);
          }
        }
        return null;
      },
      routes: <RouteBase>[
        ...getOnboardingSubtree(
          onCompleted: (BuildContext ctx) => ctx.goNamed(HomeRoutes.home.name),
        ),
        ...getHomeSubtree(),
      ],
    );
  }
}
