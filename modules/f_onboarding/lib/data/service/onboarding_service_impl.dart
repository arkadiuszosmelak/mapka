import 'package:core/core.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';
import 'package:f_onboarding/domain/service/onboarding_service.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Static onboarding content with no backend; completion is persisted in
/// [SharedPreferences] so onboarding is shown only until it's finished.
@LazySingleton(as: OnboardingService)
class OnboardingServiceImpl implements OnboardingService {
  const OnboardingServiceImpl(this._preferences);

  final SharedPreferences _preferences;

  static const String _completedKey = 'f_onboarding_completed';

  @override
  Future<Result<List<OnboardingStep>>> getSteps() async {
    // Always succeeds, so the UI never gets stuck on an error for static data.
    return const Result<List<OnboardingStep>>.success(<OnboardingStep>[
      OnboardingStep(id: 'explore', icon: OnboardingStepIcon.explore),
      OnboardingStep(id: 'save', icon: OnboardingStepIcon.save),
      OnboardingStep(id: 'share', icon: OnboardingStepIcon.share),
    ]);
  }

  @override
  Future<bool> isCompleted() async => _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> markCompleted() async => _preferences.setBool(_completedKey, true);
}
