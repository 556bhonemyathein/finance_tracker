/// Low-level, technical errors thrown by the *data* layer
/// (Dio interceptors, Isar, secure storage…).
///
/// They intentionally carry technical detail. The repository layer converts
/// them into a [Failure], which is what the UI is allowed to see.
sealed class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => '$runtimeType($message, status: $statusCode)';
}

/// No usable internet connection.
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

/// Connect/send/receive timed out.
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'The request timed out']);
}

/// 5xx — the server failed to fulfil a valid request.
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.cause});
}

/// 401/403 — token missing, expired or insufficient.
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Session expired'])
    : super(statusCode: 401);
}

/// 422/400 with a field-level error map.
class ValidationException extends AppException {
  const ValidationException(super.message, {this.fieldErrors = const {}})
    : super(statusCode: 422);

  /// Field name → list of messages, ready to be bound to form fields.
  final Map<String, List<String>> fieldErrors;
}

/// 404.
class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Not found'])
    : super(statusCode: 404);
}

/// The request was aborted (user navigated away, token refresh failed…).
class CancelledException extends AppException {
  const CancelledException([super.message = 'Request cancelled']);
}

/// Isar / secure storage / file-system failure.
class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}

/// Anything we could not classify.
class UnknownException extends AppException {
  const UnknownException(super.message, {super.cause});
}
