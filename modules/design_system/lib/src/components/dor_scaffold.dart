import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// App-standard scaffold: consistent background and a safe-area body with
/// optional symmetric horizontal padding from the spacing scale.
class DorScaffold extends StatelessWidget {
  const DorScaffold({
    required this.body,
    this.appBar,
    this.bottom,
    this.padded = true,
    super.key,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottom;
  final bool padded;

  @override
  Widget build(BuildContext context) {
    final Widget content = padded
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: context.spacing.l),
            child: body,
          )
        : body;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: appBar,
      body: SafeArea(child: content),
      bottomNavigationBar: bottom == null
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.all(context.spacing.l),
                child: bottom,
              ),
            ),
    );
  }
}
