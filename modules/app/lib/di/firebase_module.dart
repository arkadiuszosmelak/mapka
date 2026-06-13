import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:injectable/injectable.dart';

/// Firebase singletons. Resolved lazily — `Firebase.initializeApp()` must run
/// first (it does, in `bootstrap`, before anything uses these).
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
}
