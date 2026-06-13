import 'package:core/core.dart';

/// Routes owned by the app shell (not by any feature module).
abstract final class AppRoutes {
  static const RouteDefinition home = RouteDefinition(path: '/home', name: 'home');
}
