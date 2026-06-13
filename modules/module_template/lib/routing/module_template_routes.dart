import 'package:core/core.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart' hide NavigationCallback;
import 'package:module_template/presentation/page/module_template/module_template_page.dart';

/// Named routes owned by this module.
abstract final class ModuleTemplateRoutes {
  static const RouteDefinition root = RouteDefinition(
    path: '/module_template',
    name: 'module_template',
  );
}

/// Builds this module's route subtree. The app supplies the navigation
/// callbacks and composes the result into the root router.
List<RouteBase> getModuleTemplateSubtree({required NavigationCallback onContinue}) {
  return <RouteBase>[
    GoRoute(
      path: ModuleTemplateRoutes.root.path,
      name: ModuleTemplateRoutes.root.name,
      builder: (BuildContext context, GoRouterState state) => ModuleTemplatePage(onContinue: onContinue),
    ),
  ];
}
