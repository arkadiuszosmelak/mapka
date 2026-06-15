abstract final class MapboxConfig {
  static const String accessToken = String.fromEnvironment('MAPBOX_ACCESS_TOKEN');

  static const String styleUri = String.fromEnvironment(
    'MAPBOX_STYLE_URI',
    defaultValue: 'mapbox://styles/croxonero/cmqccbbi2000h01sb9vloax74',
  );

  static bool get hasToken => accessToken.isNotEmpty;
}
