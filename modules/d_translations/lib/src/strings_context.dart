import 'package:d_translations/generated/l10n.dart';
import 'package:flutter/widgets.dart';

/// Ergonomic access to shared strings: `context.strings.app_ok`.
extension StringsContext on BuildContext {
  Strings get strings => Strings.of(this);
}
