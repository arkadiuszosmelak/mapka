import 'package:injectable/injectable.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Central sink for unhandled / silently-handled errors.
///
/// The concrete binding is chosen by the composition root (the app), which
/// decorates logging with crash reporting. `fatal` distinguishes uncaught
/// crashes from handled errors for crash-reporting backends.
abstract interface class ErrorReporter {
  void silentlyReportError(Object error, {StackTrace? stackTrace, bool fatal = false});
}

/// Logging-only reporter (Talker). The app wraps this with crash reporting; it
/// is intentionally not bound to [ErrorReporter] here so `core` stays free of
/// any crash-reporting provider.
@lazySingleton
class TalkerErrorReporter implements ErrorReporter {
  const TalkerErrorReporter(this._talker);

  final Talker _talker;

  @override
  void silentlyReportError(Object error, {StackTrace? stackTrace, bool fatal = false}) {
    _talker.handle(error, stackTrace);
  }
}
