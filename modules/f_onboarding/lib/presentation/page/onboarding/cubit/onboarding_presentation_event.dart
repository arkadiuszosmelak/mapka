/// One-shot presentation effects emitted by [OnboardingCubit] and consumed by
/// the page (navigation / snackbar), kept separate from the rebuildable state.
sealed class OnboardingPresentationEvent {
  const OnboardingPresentationEvent();
}

/// Onboarding finished — the page should leave the flow via its callback.
final class OnboardingCompleted extends OnboardingPresentationEvent {
  const OnboardingCompleted();
}

/// Loading the steps failed — the page should surface [message].
final class OnboardingLoadFailed extends OnboardingPresentationEvent {
  const OnboardingLoadFailed(this.message);

  final String message;
}
