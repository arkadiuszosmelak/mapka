import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// Centered, brand-colored progress indicator.
class DorLoader extends StatelessWidget {
  const DorLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.primary),
    );
  }
}
