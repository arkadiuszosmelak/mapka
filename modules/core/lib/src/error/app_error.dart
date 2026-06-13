/// Base type for all errors surfaced to the domain/presentation layers.
///
/// Network/serialization failures are translated into one of these so the UI
/// degrades gracefully instead of crashing.
sealed class AppError implements Exception {
  const AppError(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => '$runtimeType: $message';
}

/// The request reached the server but failed (non-2xx, timeout treated below).
final class NetworkError extends AppError {
  const NetworkError(super.message, {this.statusCode, super.cause, super.stackTrace});

  final int? statusCode;
}

/// No connectivity / request never completed.
final class ConnectionError extends AppError {
  const ConnectionError(super.message, {super.cause, super.stackTrace});
}

/// A response could not be parsed into the expected shape.
final class SerializationError extends AppError {
  const SerializationError(super.message, {super.cause, super.stackTrace});
}

/// Anything we did not anticipate. Always reported to crash reporting.
final class UnknownError extends AppError {
  const UnknownError(super.message, {super.cause, super.stackTrace});
}
