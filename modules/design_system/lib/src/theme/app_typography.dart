import 'package:flutter/widgets.dart';

/// Typography tokens. Never hardcode `fontSize` in feature code — read from
/// `context.typography`. Values are color-agnostic; color comes from the theme.
class AppTypography {
  const AppTypography({
    required this.displayLarge,
    required this.titleLarge,
    required this.titleMedium,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.labelLarge,
    required this.caption,
  });

  final TextStyle displayLarge;
  final TextStyle titleLarge;
  final TextStyle titleMedium;
  final TextStyle bodyLarge;
  final TextStyle bodyMedium;
  final TextStyle labelLarge;
  final TextStyle caption;

  static const AppTypography regular = AppTypography(
    displayLarge: TextStyle(fontSize: 32, height: 1.2, fontWeight: FontWeight.w700),
    titleLarge: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w700),
    titleMedium: TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600),
    bodyLarge: TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w400),
    bodyMedium: TextStyle(fontSize: 14, height: 1.45, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 15, height: 1.2, fontWeight: FontWeight.w600),
    caption: TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w400),
  );
}
