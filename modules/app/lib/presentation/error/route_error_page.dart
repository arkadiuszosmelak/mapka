import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Shown by the router's `errorBuilder` when navigation fails (unknown route,
/// builder threw). Degrades gracefully with a localized message; the actual
/// error is reported to the `ErrorReporter` by the router, not shown to users.
class RouteErrorPage extends StatelessWidget {
  const RouteErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DorScaffold(
      appBar: AppBar(backgroundColor: context.colors.background),
      body: DorErrorBox(message: context.strings.app_error_generic),
    );
  }
}
