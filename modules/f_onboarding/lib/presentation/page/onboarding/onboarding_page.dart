import 'package:bloc_presentation/bloc_presentation.dart';
import 'package:core/core.dart';
import 'package:d_translations/d_translations.dart';
import 'package:design_system/design_system.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_cubit.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_presentation_event.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_state.dart';
import 'package:f_onboarding/presentation/page/onboarding/widgets/onboarding_step_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooked_bloc/hooked_bloc.dart';

/// Intro carousel. The final step (or "Skip") leaves to the permissions page
/// via [onGetStarted] — a callback bound in the module's `routes.dart`, so this
/// page never references another module's routes.
class OnboardingPage extends HookWidget {
  const OnboardingPage({required this.onGetStarted, super.key});

  final NavigationCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final OnboardingCubit cubit = useBloc<OnboardingCubit>();
    final OnboardingState state = useBlocBuilder(cubit);
    final PageController pageController = usePageController();
    final Strings strings = Strings.of(context);

    useEffect(
      () {
        cubit.load();
        return null;
      },
      const <Object?>[],
    );

    return BlocPresentationListener<OnboardingCubit, OnboardingPresentationEvent>(
      bloc: cubit,
      listener: (BuildContext context, OnboardingPresentationEvent event) {
        if (event is OnboardingLoadFailed) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(event.message)));
        }
      },
      child: DorScaffold(
        body: switch (state.status) {
          OnboardingStatus.initial || OnboardingStatus.loading => const DorLoader(),
          OnboardingStatus.error => DorErrorBox(
              message: strings.app_error_generic,
              retryLabel: strings.app_retry,
              onRetry: cubit.load,
            ),
          OnboardingStatus.loaded => _OnboardingContent(
              steps: state.steps,
              currentIndex: state.currentIndex,
              controller: pageController,
              onPageChanged: cubit.onPageChanged,
            ),
        },
        bottom: state.status == OnboardingStatus.loaded
            ? _OnboardingActions(
                strings: strings,
                isLastStep: state.isLastStep,
                onSkip: () => onGetStarted(context),
                onNext: () => pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                ),
                onGetStarted: () => onGetStarted(context),
              )
            : null,
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  const _OnboardingContent({
    required this.steps,
    required this.currentIndex,
    required this.controller,
    required this.onPageChanged,
  });

  final List<OnboardingStep> steps;
  final int currentIndex;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: PageView.builder(
            controller: controller,
            onPageChanged: onPageChanged,
            itemCount: steps.length,
            itemBuilder: (BuildContext context, int index) => OnboardingStepView(step: steps[index]),
          ),
        ),
        SizedBox(height: context.spacing.l),
        DorPageIndicator(count: steps.length, activeIndex: currentIndex),
        SizedBox(height: context.spacing.l),
      ],
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.strings,
    required this.isLastStep,
    required this.onSkip,
    required this.onNext,
    required this.onGetStarted,
  });

  final Strings strings;
  final bool isLastStep;
  final VoidCallback onSkip;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DorPrimaryButton(
          label: isLastStep ? strings.f_onboarding_get_started : strings.f_onboarding_next,
          onPressed: isLastStep ? onGetStarted : onNext,
        ),
        SizedBox(height: context.spacing.s),
        if (!isLastStep) DorTextButton(label: strings.f_onboarding_skip, onPressed: onSkip),
      ],
    );
  }
}
