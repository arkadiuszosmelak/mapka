import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Starting point for the module's first page. Wire a cubit via
/// `useBloc<XCubit>()` and read tokens through `context.*`.
class ModuleTemplatePage extends HookWidget {
  const ModuleTemplatePage({required this.onContinue, super.key});

  final NavigationCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return DorScaffold(
      appBar: AppBar(backgroundColor: context.colors.background),
      body: Center(
        child: Text(
          'module_template',
          style: context.typography.titleLarge.copyWith(color: context.colors.onBackground),
        ),
      ),
      bottom: DorPrimaryButton(
        label: 'Continue',
        onPressed: () => onContinue(context),
      ),
    );
  }
}
