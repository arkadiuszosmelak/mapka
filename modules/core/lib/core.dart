/// Shared foundation for the whole app.
///
/// `core` depends on nothing local — every other module depends on it.
library;

// Re-exported so feature modules can annotate DI without importing injectable
// directly and so the app can aggregate micro-package modules.
export 'package:injectable/injectable.dart' show GetItHelper, MicroPackageModule;
// Shared logger type, re-exported so modules log to the one DI-provided Talker.
export 'package:talker_flutter/talker_flutter.dart' show Talker;

// Generated micro-package module (run `melos gen`). Aggregated by the app.
export 'dependency_injection/core_package_module.module.dart' show CorePackageModule;

export 'src/architecture/base_cubit.dart';
export 'src/architecture/module_manifest.dart';
export 'src/architecture/route_definition.dart';
export 'src/architecture/route_guard.dart';
export 'src/error/app_error.dart';
export 'src/error/error_reporter.dart';
export 'src/flavor/app_flavor.dart';
export 'src/navigation/navigation_callback.dart';
export 'src/result/result.dart';
