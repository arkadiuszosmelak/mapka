import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/theme/app_radius.dart';
import 'package:design_system/src/theme/app_spacing.dart';
import 'package:design_system/src/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Bundles every design token and rides on [ThemeData] as a [ThemeExtension],
/// so tokens are read through `context` rather than imported globals.
@immutable
class DesignSystemTheme extends ThemeExtension<DesignSystemTheme> {
  const DesignSystemTheme({
    required this.colors,
    required this.typography,
    required this.spacing,
    required this.radius,
  });

  final AppColors colors;
  final AppTypography typography;
  final AppSpacing spacing;
  final AppRadius radius;

  @override
  DesignSystemTheme copyWith({
    AppColors? colors,
    AppTypography? typography,
    AppSpacing? spacing,
    AppRadius? radius,
  }) {
    return DesignSystemTheme(
      colors: colors ?? this.colors,
      typography: typography ?? this.typography,
      spacing: spacing ?? this.spacing,
      radius: radius ?? this.radius,
    );
  }

  @override
  DesignSystemTheme lerp(covariant ThemeExtension<DesignSystemTheme>? other, double t) {
    // Tokens are discrete sets; snap to the target half-way through.
    if (other is! DesignSystemTheme) {
      return this;
    }
    return t < 0.5 ? this : other;
  }
}

/// Token access via `context`: `context.colors`, `context.typography`,
/// `context.spacing`, `context.radius`, `context.designSystem`.
extension DesignSystemContext on BuildContext {
  DesignSystemTheme get designSystem => Theme.of(this).extension<DesignSystemTheme>()!;
  AppColors get colors => designSystem.colors;
  AppTypography get typography => designSystem.typography;
  AppSpacing get spacing => designSystem.spacing;
  AppRadius get radius => designSystem.radius;
}
