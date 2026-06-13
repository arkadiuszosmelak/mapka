import 'package:equatable/equatable.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';

enum OnboardingStatus { initial, loading, loaded, error }

/// Single-class state with a status enum + `copyWith` (pattern 3 from the
/// foundations doc), since the carousel also tracks the current page index.
class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.steps = const <OnboardingStep>[],
    this.currentIndex = 0,
  });

  final OnboardingStatus status;
  final List<OnboardingStep> steps;
  final int currentIndex;

  bool get isLastStep => steps.isNotEmpty && currentIndex >= steps.length - 1;

  OnboardingState copyWith({
    OnboardingStatus? status,
    List<OnboardingStep>? steps,
    int? currentIndex,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      steps: steps ?? this.steps,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, steps, currentIndex];
}
