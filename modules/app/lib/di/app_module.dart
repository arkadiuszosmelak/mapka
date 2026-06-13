import 'package:flutter/widgets.dart';
import 'package:injectable/injectable.dart';

/// App-scope DI bindings that aren't owned by any feature module.
@module
abstract class AppModule {
  /// Root navigator key — used by the router and for navigation/overlays from
  /// outside the widget tree (e.g. global error UI).
  @lazySingleton
  GlobalKey<NavigatorState> get rootNavigatorKey =>
      GlobalKey<NavigatorState>(debugLabel: 'rootNavigator');
}
