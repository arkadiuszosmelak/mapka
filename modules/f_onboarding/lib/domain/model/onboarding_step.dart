import 'package:equatable/equatable.dart';

/// Visual identity of an onboarding step. The presentation layer maps each
/// value to a localized title/description and an icon, so the domain model
/// stays free of UI strings.
enum OnboardingStepIcon { explore, save, share }

/// A single onboarding slide.
class OnboardingStep extends Equatable {
  const OnboardingStep({required this.id, required this.icon});

  final String id;
  final OnboardingStepIcon icon;

  @override
  List<Object?> get props => <Object?>[id, icon];
}
