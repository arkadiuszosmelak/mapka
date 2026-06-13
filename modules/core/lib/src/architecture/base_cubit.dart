import 'package:bloc/bloc.dart';
import 'package:bloc_presentation/bloc_presentation.dart';

/// Base class for every Cubit in the app.
///
/// - [S] is the state type (should `extend Equatable`).
/// - [E] is the one-shot presentation event type (snackbar, dialog, navigation)
///   emitted via [emitPresentation] and consumed by the page through the
///   `presentation` stream.
abstract class BaseCubit<S, E> extends Cubit<S> with BlocPresentationMixin<S, E> {
  BaseCubit(super.initialState);
}

/// Base class for the rare cases that genuinely need event-stream transforms
/// (debounce / throttle / concurrency via `bloc_concurrency`).
abstract class BaseBloc<Event, S, E> extends Bloc<Event, S> with BlocPresentationMixin<S, E> {
  BaseBloc(super.initialState);
}
