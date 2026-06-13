import 'package:design_system/src/theme/app_colors.dart';
import 'package:design_system/src/theme/app_radius.dart';
import 'package:design_system/src/theme/app_spacing.dart';
import 'package:design_system/src/theme/app_typography.dart';
import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// Builds the app's [ThemeData], wiring design tokens into both the Material
/// [ColorScheme] (for stock widgets) and the [DesignSystemTheme] extension
/// (for `Dor*` components and `context.*` token access).
abstract final class AppTheme {
  static ThemeData light() => _build(Brightness.light, AppColors.light);

  static ThemeData dark() => _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    const AppTypography typography = AppTypography.regular;
    const AppSpacing spacing = AppSpacing.regular;
    const AppRadius radius = AppRadius.regular;

    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      secondary: colors.primary,
      onSecondary: colors.onPrimary,
      surface: colors.surface,
      onSurface: colors.onSurface,
      error: colors.error,
      onError: colors.onError,
      outline: colors.outline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      extensions: <ThemeExtension<dynamic>>[
        DesignSystemTheme(
          colors: colors,
          typography: typography,
          spacing: spacing,
          radius: radius,
        ),
      ],
    );
  }
}
