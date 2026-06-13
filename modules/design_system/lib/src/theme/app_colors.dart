import 'package:flutter/widgets.dart';

/// Semantic color tokens. Never hardcode `Color(...)` in feature code — read
/// from `context.colors`.
class AppColors {
  const AppColors({
    required this.primary,
    required this.onPrimary,
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.background,
    required this.onBackground,
    required this.outline,
    required this.error,
    required this.onError,
    required this.success,
  });

  final Color primary;
  final Color onPrimary;
  final Color surface;
  final Color onSurface;
  final Color surfaceVariant;
  final Color background;
  final Color onBackground;
  final Color outline;
  final Color error;
  final Color onError;
  final Color success;

  static const AppColors light = AppColors(
    primary: Color(0xFF3D5AFE),
    onPrimary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B1C1E),
    surfaceVariant: Color(0xFFF1F3F5),
    background: Color(0xFFFAFBFC),
    onBackground: Color(0xFF1B1C1E),
    outline: Color(0xFFD0D5DD),
    error: Color(0xFFD92D20),
    onError: Color(0xFFFFFFFF),
    success: Color(0xFF12B76A),
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF8C9EFF),
    onPrimary: Color(0xFF0B1020),
    surface: Color(0xFF1B1C1E),
    onSurface: Color(0xFFF5F6F7),
    surfaceVariant: Color(0xFF2A2C30),
    background: Color(0xFF131416),
    onBackground: Color(0xFFF5F6F7),
    outline: Color(0xFF3A3D42),
    error: Color(0xFFF97066),
    onError: Color(0xFF1B1C1E),
    success: Color(0xFF32D583),
  );
}
