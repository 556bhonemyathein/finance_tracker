import 'app_exception.dart';

/// A *presentation-safe* error.
///
/// Repositories never let an [AppException] escape to the UI: they map it to a
/// [Failure] carrying a message that is safe and friendly to show a user.
/// Modelled as a sealed class so `switch` over failures is exhaustive — the
/// compiler tells us when a new failure type needs UI handling.
sealed class Failure {
  const Failure(this.message, {this.debugMessage});

  /// User-facing, already-friendly text.
  final String message;

  /// Technical detail: logged and reported, never rendered.
  final String? debugMessage;

  /// Whether offering a "Retry" button makes sense for this failure.
  bool get isRetryable => switch (this) {
    NetworkFailure() || TimeoutFailure() || ServerFailure() => true,
    _ => false,
  };

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    String message = 'You appear to be offline. Changes are saved on device.',
    super.debugMessage,
  }) : super(message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({
    String message = 'That took too long. Please try again.',
    super.debugMessage,
  }) : super(message);
}

class ServerFailure extends Failure {
  const ServerFailure({
    String message = 'Something went wrong on our side.',
    super.debugMessage,
  }) : super(message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    String message = 'Your session expired. Please sign in again.',
    super.debugMessage,
  }) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
    super.debugMessage,
  });

  /// Field name → messages, ready to bind to form fields.
  final Map<String, List<String>> fieldErrors;

  /// First message for [field], if the backend rejected it.
  String? errorFor(String field) => fieldErrors[field]?.firstOrNull;
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    String message = 'We could not find what you were looking for.',
    super.debugMessage,
  }) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure({
    String message = 'Could not read local data.',
    super.debugMessage,
  }) : super(message);
}

class CancelledFailure extends Failure {
  const CancelledFailure({
    String message = 'Request cancelled.',
    super.debugMessage,
  }) : super(message);
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    String message = 'Unexpected error. Please try again.',
    super.debugMessage,
  }) : super(message);
}

/// Single place that translates data-layer exceptions into UI failures.
///
/// One mapper (instead of a bespoke `try/catch` per repository method) is what
/// keeps error handling consistent across every feature.
abstract final class FailureMapper {
  static Failure from(Object error, [StackTrace? stackTrace]) {
    if (error is Failure) return error;

    if (error is AppException) {
      final String debug = error.toString();
      return switch (error) {
        NetworkException() => NetworkFailure(debugMessage: debug),
        TimeoutException() => TimeoutFailure(debugMessage: debug),
        UnauthorizedException() => UnauthorizedFailure(debugMessage: debug),
        ValidationException(:final message, :final fieldErrors) =>
          ValidationFailure(
            message,
            fieldErrors: fieldErrors,
            debugMessage: debug,
          ),
        NotFoundException() => NotFoundFailure(debugMessage: debug),
        ServerException() => ServerFailure(debugMessage: debug),
        CacheException() => CacheFailure(debugMessage: debug),
        CancelledException() => CancelledFailure(debugMessage: debug),
        UnknownException() => UnknownFailure(debugMessage: debug),
      };
    }

    return UnknownFailure(debugMessage: '$error\n$stackTrace');
  }
}
