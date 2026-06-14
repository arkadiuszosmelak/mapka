import 'package:core/core.dart';
import 'package:f_home/presentation/page/home/home_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart' hide NavigationCallback;

/// Named routes owned by the home module.
abstract final class HomeRoutes {
  static const RouteDefinition home = RouteDefinition(path: '/home', name: 'home');
}

/// Builds the home route subtree. Composed into the root router by the app.
List<RouteBase> getHomeSubtree() {
  return <RouteBase>[
    GoRoute(
      path: HomeRoutes.home.path,
      name: HomeRoutes.home.name,
      builder: (BuildContext context, GoRouterState state) => const HomePage(),
    ),
  ];
}
