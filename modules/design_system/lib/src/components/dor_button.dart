import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// Primary call-to-action button. Sizing, color and radius come from tokens.
class DorPrimaryButton extends StatelessWidget {
  const DorPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.expand = true,
    super.key,
  });

  final String label;

  /// `null` disables the button.
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.onPrimary,
      disabledBackgroundColor: context.colors.outline,
      minimumSize: Size(expand ? double.infinity : 0, 52),
      textStyle: context.typography.labelLarge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.radius.m),
      ),
    );

    return ElevatedButton(
      style: style,
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: context.colors.onPrimary,
              ),
            )
          : Text(label),
    );
  }
}

/// Low-emphasis text button for secondary actions (e.g. "Skip").
class DorTextButton extends StatelessWidget {
  const DorTextButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: context.colors.onBackground,
        textStyle: context.typography.labelLarge,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
