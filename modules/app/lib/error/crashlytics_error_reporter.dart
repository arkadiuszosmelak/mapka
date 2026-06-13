import 'package:core/core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';

/// The app's [ErrorReporter]: logs every error to Talker and records it to
/// Firebase Crashlytics. Handled errors are non-fatal; uncaught errors are
/// reported with `fatal: true` from `bootstrap`.
@LazySingleton(as: ErrorReporter)
class CrashlyticsErrorReporter implements ErrorReporter {
  const CrashlyticsErrorReporter(this._logger, this._crashlytics);

  final TalkerErrorReporter _logger;
  final FirebaseCrashlytics _crashlytics;

  @override
  void silentlyReportError(Object error, {StackTrace? stackTrace, bool fatal = false}) {
    _logger.silentlyReportError(error, stackTrace: stackTrace, fatal: fatal);
    _crashlytics.recordError(error, stackTrace, fatal: fatal);
  }
}
