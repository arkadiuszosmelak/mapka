import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

class DorLoader extends StatelessWidget {
  final double? strokeWidth;
  const DorLoader({this.strokeWidth, super.key});

  @override
  Widget build(BuildContext context) => Center(
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: context.colors.primary,
        ),
      );
}
