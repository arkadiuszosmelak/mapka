import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Placeholder destination after onboarding completes. Replace with a real
/// feature module (e.g. `f_home`) generated via `tools/create_module.sh`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DorScaffold(
      appBar: AppBar(title: const Text('Mapka'), backgroundColor: context.colors.background),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.map_outlined, size: 72, color: context.colors.primary),
            SizedBox(height: context.spacing.l),
            Text(
              context.strings.app_ok,
              style: context.typography.titleLarge.copyWith(color: context.colors.onBackground),
            ),
          ],
        ),
      ),
    );
  }
}
