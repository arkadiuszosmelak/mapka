import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:core/core.dart';
import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_cubit.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_presentation_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Final onboarding step: a location-consent screen. Both actions complete the
/// flow; [onCompleted] (provided by the app) decides where to go next.
class OnboardingPermissionsPage extends HookWidget {
  const OnboardingPermissionsPage({required this.onCompleted, super.key});

  final NavigationCallback onCompleted;

  @override
  Widget build(BuildContext context) {
    final OnboardingCubit cubit = useBloc<OnboardingCubit>();
    final Strings strings = Strings.of(context);

    return BlocPresentationListener<OnboardingCubit, OnboardingPresentationEvent>(
      bloc: cubit,
      listener: (BuildContext context, OnboardingPresentationEvent event) {
        if (event is OnboardingCompleted) {
          onCompleted(context);
        }
      },
      child: DorScaffold(
        appBar: AppBar(backgroundColor: context.colors.background),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.location_on_outlined, size: 72, color: context.colors.primary),
            SizedBox(height: context.spacing.xl),
            Text(
              strings.f_onboarding_permissions_title,
              textAlign: TextAlign.center,
              style: context.typography.titleLarge.copyWith(color: context.colors.onBackground),
            ),
            SizedBox(height: context.spacing.m),
            Text(
              strings.f_onboarding_permissions_body,
              textAlign: TextAlign.center,
              style: context.typography.bodyLarge.copyWith(color: context.colors.onBackground),
            ),
          ],
        ),
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DorPrimaryButton(
              label: strings.f_onboarding_permissions_allow,
              onPressed: cubit.complete,
            ),
            SizedBox(height: context.spacing.s),
            DorTextButton(
              label: strings.f_onboarding_permissions_not_now,
              onPressed: cubit.complete,
            ),
          ],
        ),
      ),
    );
  }
}
