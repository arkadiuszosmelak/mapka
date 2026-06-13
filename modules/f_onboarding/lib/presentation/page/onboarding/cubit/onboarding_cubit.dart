import 'package:core/core.dart';
import 'package:f_onboarding/domain/model/onboarding_step.dart';
import 'package:f_onboarding/domain/service/onboarding_service.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_presentation_event.dart';
import 'package:f_onboarding/presentation/page/onboarding/cubit/onboarding_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class OnboardingCubit extends BaseCubit<OnboardingState, OnboardingPresentationEvent> {
  OnboardingCubit(this._service) : super(const OnboardingState());

  final OnboardingService _service;

  Future<void> load() async {
    emit(state.copyWith(status: OnboardingStatus.loading));
    final Result<List<OnboardingStep>> result = await _service.getSteps();
    result.fold(
      onSuccess: (List<OnboardingStep> steps) => emit(
        state.copyWith(status: OnboardingStatus.loaded, steps: steps),
      ),
      onFailure: (AppError error) {
        emit(state.copyWith(status: OnboardingStatus.error));
        emitPresentation(OnboardingLoadFailed(error.message));
      },
    );
  }

  void onPageChanged(int index) => emit(state.copyWith(currentIndex: index));

  Future<void> complete() async {
    await _service.markCompleted();
    emitPresentation(const OnboardingCompleted());
  }
}
