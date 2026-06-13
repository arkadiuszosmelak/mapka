import 'dart:async';

import 'package:core/src/architecture/route_definition.dart';
import 'package:go_router/go_router.dart';

/// A guard contributed by a module (or the app) that can redirect navigation
/// before a route is shown.
///
/// Async by design so guards can consult storage / a session / a service
/// (the most common case: "skip onboarding if already completed"). Returning a
/// [RouteDefinition] redirects there; returning `null` allows navigation.
///
/// The router invokes each guard inside a try/catch and reports failures to the
/// error reporter, so a throwing guard never breaks navigation.
abstract class RouteGuard {
  const RouteGuard();

  FutureOr<RouteDefinition?> call(GoRouterState state);
}
