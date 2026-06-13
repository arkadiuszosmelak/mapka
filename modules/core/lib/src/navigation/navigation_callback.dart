import 'package:flutter/widgets.dart';

/// A navigation intent handed to a page so it never reaches for routes that
/// belong to another module.
///
/// Pages receive callbacks such as `onLoginSuccess` / `onGoToHome`; the actual
/// route binding happens in the owning module's `routes.dart`.
typedef NavigationCallback = void Function(BuildContext context);

/// A navigation callback that carries a single argument (e.g. an id).
typedef NavigationCallbackWith<T> = void Function(BuildContext context, T value);
