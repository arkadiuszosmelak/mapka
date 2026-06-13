/// Build flavor / environment the app is running as.
///
/// Selected at startup by the entry point (`main_dev.dart` etc.) and registered
/// in DI, so any service can depend on it. Keep environment-specific values
/// (API base URL, analytics keys) keyed off this — per project, not here.
enum AppFlavor {
  dev,
  staging,
  prod;

  bool get isProduction => this == AppFlavor.prod;

  /// Human-facing app title (also used for the non-prod corner banner).
  String get title => switch (this) {
        AppFlavor.dev => 'Mapka Dev',
        AppFlavor.staging => 'Mapka Staging',
        AppFlavor.prod => 'Mapka',
      };
}
