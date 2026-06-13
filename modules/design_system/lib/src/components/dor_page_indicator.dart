import 'package:design_system/src/theme/design_system_theme.dart';
import 'package:flutter/material.dart';

/// Row of dots indicating the active page in a paged flow (e.g. onboarding).
class DorPageIndicator extends StatelessWidget {
  const DorPageIndicator({
    required this.count,
    required this.activeIndex,
    super.key,
  });

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? context.colors.primary : context.colors.outline,
            borderRadius: BorderRadius.circular(context.radius.full),
          ),
        );
      }),
    );
  }
}
