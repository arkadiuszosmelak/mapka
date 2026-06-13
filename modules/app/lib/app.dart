import 'package:app/di/injection.dart';
import 'package:core/core.dart';
import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Root widget. Wires the design-system theme, every module's localization
/// delegate, the composed router, and the `hooked_bloc` injector (so
/// `useBloc<T>()` resolves cubits from [getIt]).
class MapkaApp extends StatelessWidget {
  const MapkaApp({required this.router, required this.flavor, super.key});

  final GoRouter router;
  final AppFlavor flavor;

  @override
  Widget build(BuildContext context) {
    return HookedBlocConfigProvider(
      injector: () => getIt,
      child: MaterialApp.router(
        title: flavor.title,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: router,
        builder: (BuildContext context, Widget? child) {
          final Widget content = child ?? const SizedBox.shrink();
          if (flavor.isProduction) {
            return content;
          }
          return Banner(
            message: flavor.name,
            location: BannerLocation.topEnd,
            child: content,
          );
        },
        localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
          Strings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: Strings.delegate.supportedLocales,
      ),
    );
  }
}
