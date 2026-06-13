/// Canonical identity of a route: its `path` and its `name`.
///
/// Modules expose `static const RouteDefinition` constants instead of enums, so
/// routing, navigation and guards all reference the same value. Navigate by
/// [name]; never hardcode paths.
class RouteDefinition {
  const RouteDefinition({required this.path, required this.name});

  final String path;
  final String name;

  @override
  bool operator ==(Object other) =>
      other is RouteDefinition && other.path == path && other.name == name;

  @override
  int get hashCode => Object.hash(path, name);

  @override
  String toString() => 'RouteDefinition($name -> $path)';
}
