import 'package:app/bootstrap.dart';
import 'package:core/core.dart';

/// Default entry point (`flutter run` with no `-t`) — runs the dev flavor.
/// Use the flavor-specific entry points / launch configs for staging and prod.
void main() => bootstrap(AppFlavor.dev);
