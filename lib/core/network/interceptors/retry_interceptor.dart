import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../utils/app_logger.dart';

/// Retries transient failures with exponential backoff.
///
/// Two rules keep this safe:
///   * only *idempotent* verbs are retried (GET/HEAD/PUT/DELETE) — replaying a
///     POST could create a duplicate transaction;
///   * only transient causes are retried (timeouts, connection drops, 5xx,
///     429) — a 400 will fail identically no matter how often we ask.
class RetryInterceptor extends Interceptor {
  RetryInterceptor(
    this._dio, {
    this.maxRetries = AppConstants.maxNetworkRetries,
  });

  final Dio _dio;
  final int maxRetries;

  static const Set<String> _idempotentMethods = <String>{
    'GET',
    'HEAD',
    'PUT',
    'DELETE',
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions options = err.requestOptions;
    final int attempt = (options.extra['pp_retry_attempt'] as int?) ?? 0;

    if (!_shouldRetry(err) || attempt >= maxRetries) {
      return handler.next(err);
    }

    // 200ms, 400ms, 800ms — enough to ride out a blip without stalling the UI.
    final Duration delay = Duration(milliseconds: 200 * (1 << attempt));
    AppLogger.w(
      'Retrying ${options.method} ${options.path} '
      '(attempt ${attempt + 1}/$maxRetries) in ${delay.inMilliseconds}ms',
    );
    await Future<void>.delayed(delay);

    options.extra['pp_retry_attempt'] = attempt + 1;
    try {
      handler.resolve(await _dio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  bool _shouldRetry(DioException err) {
    if (!_idempotentMethods.contains(err.requestOptions.method.toUpperCase())) {
      return false;
    }
    final int? status = err.response?.statusCode;
    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      DioExceptionType.badResponse => status == 429 || (status ?? 0) >= 500,
      _ => false,
    };
  }
}
