/// Named corner-radius scale. Read values from `context.radius`.
class AppRadius {
  const AppRadius({
    this.s = 8,
    this.m = 12,
    this.l = 20,
    this.full = 999,
  });

  final double s;
  final double m;
  final double l;
  final double full;

  static const AppRadius regular = AppRadius();
}
