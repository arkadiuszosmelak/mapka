import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class LocatingIndicator extends StatelessWidget {
  const LocatingIndicator({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.only(top: context.spacing.m),
            child: Material(
              elevation: 3,
              color: context.colors.surface,
              borderRadius: BorderRadius.circular(context.radius.full),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: context.spacing.m, vertical: context.spacing.s),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: context.spacing.m,
                      height: context.spacing.m,
                      child: const DorLoader(strokeWidth: 2),
                    ),
                    SizedBox(width: context.spacing.s),
                    Text(
                      label,
                      style: context.typography.bodyMedium.copyWith(color: context.colors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
