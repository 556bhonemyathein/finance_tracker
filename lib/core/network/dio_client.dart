import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_logger.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Builds the configured [Dio] instance.
///
/// Interceptor order matters and is deliberate:
///   1. `AuthInterceptor`  — adds the token, handles 401 + refresh
///   2. `RetryInterceptor` — replays transient failures
///   3. `LogInterceptor`   — records what actually went over the wire
///   4. `ErrorInterceptor` — last, so it types whatever the others gave up on
class DioClient {
  DioClient({
    required AppConfig config,
    required SecureStorageService storage,
    required Future<void> Function() onSessionExpired,
  }) {
    _dio = _createBase(config);

    // A bare client for token refresh and retries: it shares the base options
    // but has no interceptors, so it can never recurse into auth handling.
    final Dio bareClient = _createBase(config);

    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(
        storage: storage,
        refreshClient: bareClient,
        onSessionExpired: onSessionExpired,
      ),
      RetryInterceptor(bareClient),
      if (config.enableLogging)
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: AppLogger.d,
        ),
      ErrorInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;

  static Dio _createBase(AppConfig config) => Dio(
    BaseOptions(
      baseUrl: config.apiBaseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      sendTimeout: config.sendTimeout,
      headers: const <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Only 2xx counts as success: every other status must become a
      // DioException so AuthInterceptor can see 401s and ErrorInterceptor can
      // type the rest.
      validateStatus: (int? status) =>
          status != null && status >= 200 && status < 300,
    ),
  );
}
