import 'dart:async';

import 'package:app/app.dart';
import 'package:app/di/injection.dart';
import 'package:app/modules.dart';
import 'package:app/routing/app_router.dart';
import 'package:core/core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:talker_bloc_logger/talker_bloc_logger.dart';

/// Shared startup for every flavor entry point (`main_dev.dart` etc.).
///
/// Runs the app inside a guarded zone and funnels every uncaught error —
/// framework, platform and zone — into [ErrorReporter] (→ Talker + Crashlytics,
/// `fatal: true`). Handled errors reported elsewhere stay non-fatal.
void bootstrap(AppFlavor flavor) {
  runZonedGuarded(
    () async {
      final WidgetsBinding binding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: binding);

      await configureDependencies(flavor: flavor, modules: appModules);
      await Firebase.initializeApp();

      if (MapboxConfig.hasToken) {
        MapboxOptions.setAccessToken(MapboxConfig.accessToken);
      }

      final ErrorReporter errorReporter = getIt<ErrorReporter>();
      // No crash collection in debug — keeps the Crashlytics console clean.
      await getIt<FirebaseCrashlytics>().setCrashlyticsCollectionEnabled(!kDebugMode);

      FlutterError.onError = (FlutterErrorDetails details) {
        errorReporter.silentlyReportError(details.exception, stackTrace: details.stack, fatal: true);
      };
      binding.platformDispatcher.onError = (Object error, StackTrace stack) {
        errorReporter.silentlyReportError(error, stackTrace: stack, fatal: true);
        return true;
      };
      Bloc.observer = TalkerBlocObserver(talker: getIt<Talker>());

      final AppRouter router = getIt<AppRouter>();
      runApp(MapkaApp(router: router.config, flavor: flavor));
      FlutterNativeSplash.remove();
    },
    (Object error, StackTrace stack) {
      getIt<ErrorReporter>().silentlyReportError(error, stackTrace: stack, fatal: true);
    },
  );
}
