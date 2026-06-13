import 'package:core/src/error/app_error.dart';

/// Outcome of an operation that can fail: [Success] or [Failure].
///
/// Used instead of throwing across the service boundary so callers handle the
/// error path explicitly (the "Either<Error, Success>" of the foundations doc).
sealed class Result<S> {
  const Result();

  /// Wraps a successful value.
  const factory Result.success(S value) = Success<S>;

  /// Wraps a failure.
  const factory Result.failure(AppError error) = Failure<S>;

  /// Folds both branches into a single value.
  T fold<T>({
    required T Function(S value) onSuccess,
    required T Function(AppError error) onFailure,
  }) {
    return switch (this) {
      Success<S>(:final S value) => onSuccess(value),
      Failure<S>(:final AppError error) => onFailure(error),
    };
  }

  /// `true` when this is a [Success].
  bool get isSuccess => this is Success<S>;
}

final class Success<S> extends Result<S> {
  const Success(this.value);

  final S value;
}

final class Failure<S> extends Result<S> {
  const Failure(this.error);

  final AppError error;
}
