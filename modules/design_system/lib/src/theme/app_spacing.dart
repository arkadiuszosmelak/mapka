/// Named spacing scale. Never use magic numbers for padding/margins — read
/// values from `context.spacing`.
class AppSpacing {
  const AppSpacing({
    this.xxs = 2,
    this.xs = 4,
    this.s = 8,
    this.sm = 12,
    this.m = 16,
    this.l = 24,
    this.xl = 32,
    this.xxl = 48,
  });

  final double xxs;
  final double xs;
  final double s;
  final double sm;
  final double m;
  final double l;
  final double xl;
  final double xxl;

  static const AppSpacing regular = AppSpacing();
}
