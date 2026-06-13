import 'package:core/src/architecture/route_guard.dart';
import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// Everything a module contributes to the application shell.
///
/// The app collects one [ModuleManifest] per module and assembles from them:
/// the DI registration, the route guards and the navigator observers.
///
/// Routes themselves are contributed separately through each module's
/// `getSubtree(...)` function, because they require navigation callbacks the
/// manifest cannot know about (see the routing section of the foundations doc).
abstract class ModuleManifest {
  const ModuleManifest();

  /// Injectable micro-package module aggregated into the app's `GetIt`.
  ///
  /// `null` when the module registers nothing (e.g. a pure-UI module).
  MicroPackageModule? get dependencyInjectionModule => null;

  /// Route guards contributed by this module.
  List<RouteGuard> get routeGuards => const <RouteGuard>[];

  /// Navigator observers contributed by this module.
  List<NavigatorObserver> get routeObservers => const <NavigatorObserver>[];
}
