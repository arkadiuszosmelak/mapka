import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';
import 'package:flutter/material.dart';

/// Renders a single onboarding slide. Title/description/icon are derived from
/// the step's [OnboardingStepIcon] and localized here, keeping strings in this
/// module's own intl class.
class OnboardingStepView extends StatelessWidget {
  const OnboardingStepView({required this.step, super.key});

  final OnboardingStep step;

  @override
  Widget build(BuildContext context) {
    final Strings strings = Strings.of(context);
    final (String title, String description, IconData icon) content = switch (step.icon) {
      OnboardingStepIcon.explore => (
          strings.f_onboarding_step_explore_title,
          strings.f_onboarding_step_explore_description,
          Icons.explore_outlined,
        ),
      OnboardingStepIcon.save => (
          strings.f_onboarding_step_save_title,
          strings.f_onboarding_step_save_description,
          Icons.bookmark_outline,
        ),
      OnboardingStepIcon.share => (
          strings.f_onboarding_step_share_title,
          strings.f_onboarding_step_share_description,
          Icons.ios_share_outlined,
        ),
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            borderRadius: BorderRadius.circular(context.radius.l),
          ),
          child: Padding(
            padding: EdgeInsets.all(context.spacing.xl),
            child: Icon(content.$3, size: 72, color: context.colors.primary),
          ),
        ),
        SizedBox(height: context.spacing.xl),
        Text(
          content.$1,
          textAlign: TextAlign.center,
          style: context.typography.titleLarge.copyWith(color: context.colors.onBackground),
        ),
        SizedBox(height: context.spacing.m),
        Text(
          content.$2,
          textAlign: TextAlign.center,
          style: context.typography.bodyLarge.copyWith(color: context.colors.onBackground),
        ),
      ],
    );
  }
}
