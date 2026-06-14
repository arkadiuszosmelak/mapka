import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Landing screen shown after onboarding completes.
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
              context.strings.f_home_title,
              style: context.typography.titleLarge.copyWith(color: context.colors.onBackground),
            ),
          ],
        ),
      ),
    );
  }
}
