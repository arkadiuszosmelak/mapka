import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class RouteChips extends StatelessWidget {
  const RouteChips({required this.labels, required this.selectedIndex, required this.onSelected, super.key});

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.all(context.spacing.m),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (int i = 0; i < labels.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : context.spacing.s),
                    child: _Chip(
                      label: labels[i],
                      selected: i == selectedIndex,
                      onTap: () => onSelected(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color background = selected ? context.colors.primary : context.colors.surface;
    final Color foreground = selected ? context.colors.onPrimary : context.colors.onSurface;
    return Material(
      elevation: 3,
      color: background,
      borderRadius: BorderRadius.circular(context.radius.full),
      child: InkWell(
        borderRadius: BorderRadius.circular(context.radius.full),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.spacing.m, vertical: context.spacing.s),
          child: Text(label, style: context.typography.bodyMedium.copyWith(color: foreground)),
        ),
      ),
    );
  }
}
