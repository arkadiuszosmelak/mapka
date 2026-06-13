import 'package:core/core.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';

/// Onboarding domain boundary. The interface lives in `domain`; the
/// implementation lives in `data` and is wired via DI (DIP).
abstract interface class OnboardingService {
  /// Returns the onboarding steps to display.
  Future<Result<List<OnboardingStep>>> getSteps();

  /// Marks onboarding as completed so it is not shown again.
  Future<void> markCompleted();

  /// Whether onboarding has already been completed.
  Future<bool> isCompleted();
}
