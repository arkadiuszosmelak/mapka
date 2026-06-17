sealed class HomePresentationEvent {
  const HomePresentationEvent();
}

final class HomeLocationDenied extends HomePresentationEvent {
  const HomeLocationDenied({required this.canOpenSettings});

  /// `true` when denied permanently — offer a jump to system settings.
  final bool canOpenSettings;
}

final class HomeLocationDisabled extends HomePresentationEvent {
  const HomeLocationDisabled();
}

/// One-shot: fires even when already following.
final class RecenterRequested extends HomePresentationEvent {
  const RecenterRequested();
}

final class HomeRouteFailed extends HomePresentationEvent {
  const HomeRouteFailed();
}
