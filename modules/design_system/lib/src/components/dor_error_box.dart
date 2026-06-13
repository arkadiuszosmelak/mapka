import 'package:design_system/src/components/dor_button.dart';
import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// Inline error state with an optional retry action. Used so network/service
/// failures degrade gracefully instead of showing a blank screen.
class DorErrorBox extends StatelessWidget {
  const DorErrorBox({
    required this.message,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.error_outline, color: context.colors.error, size: 40),
          SizedBox(height: context.spacing.m),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.typography.bodyMedium.copyWith(color: context.colors.onBackground),
          ),
          if (onRetry != null) ...<Widget>[
            SizedBox(height: context.spacing.l),
            DorPrimaryButton(
              label: retryLabel ?? 'Retry',
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
