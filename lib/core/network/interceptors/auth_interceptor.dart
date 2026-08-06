import 'dart:async';

import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/secure_storage_service.dart';
import '../../utils/app_logger.dart';

/// Attaches the JWT and transparently refreshes it on a 401.
///
/// The tricky part of token refresh is concurrency: if five requests fire and
/// all get a 401, a naive implementation performs five refreshes and four of
/// them invalidate the fifth. [_refreshCompleter] collapses them into one —
/// the first 401 starts the refresh, the rest await the same future.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SecureStorageService storage,
    required Dio refreshClient,
    required Future<void> Function() onSessionExpired,
  }) : _storage = storage,
       _refreshClient = refreshClient,
       _onSessionExpired = onSessionExpired;

  final SecureStorageService _storage;

  /// A *separate* Dio without this interceptor, so refreshing can never
  /// recurse into itself.
  final Dio _refreshClient;

  final Future<void> Function() _onSessionExpired;

  Completer<String?>? _refreshCompleter;

  /// Endpoints that must not carry (or retry with) an access token.
  static const Set<String> _publicPaths = <String>{
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.refreshToken,
    ApiEndpoints.forgotPassword,
    ApiEndpoints.verifyOtp,
    ApiEndpoints.resetPassword,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_publicPaths.contains(options.path)) {
      final String? token = await _storage.accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final RequestOptions request = err.requestOptions;
    final bool isAuthError = err.response?.statusCode == 401;
    final bool alreadyRetried = request.extra['pp_retried_auth'] == true;

    if (!isAuthError || alreadyRetried || _publicPaths.contains(request.path)) {
      return handler.next(err);
    }

    final String? newToken = await _refreshToken();
    if (newToken == null) {
      await _onSessionExpired();
      return handler.next(err);
    }

    try {
      request
        ..headers['Authorization'] = 'Bearer $newToken'
        ..extra['pp_retried_auth'] = true;
      final Response<dynamic> response = await _refreshClient.fetch<dynamic>(
        request,
      );
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Returns a fresh access token, or `null` when the session is truly dead.
  Future<String?> _refreshToken() {
    // Collapse concurrent refreshes into the single in-flight one.
    final Completer<String?>? inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final Completer<String?> completer = Completer<String?>();
    _refreshCompleter = completer;

    unawaited(
      _performRefresh().then((String? token) {
        completer.complete(token);
        _refreshCompleter = null;
      }).catchError((Object error) {
        completer.complete(null);
        _refreshCompleter = null;
      }),
    );

    return completer.future;
  }

  Future<String?> _performRefresh() async {
    final String? refreshToken = await _storage.refreshToken;
    if (refreshToken == null) return null;

    try {
      final Response<Map<String, dynamic>> response = await _refreshClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.refreshToken,
            data: <String, dynamic>{'refreshToken': refreshToken},
          );

      final Map<String, dynamic>? body = response.data;
      final String? access = body?['accessToken'] as String?;
      final String? refresh = body?['refreshToken'] as String?;
      if (access == null || refresh == null) return null;

      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      AppLogger.i('Access token refreshed');
      return access;
    } on DioException catch (error, stackTrace) {
      AppLogger.w('Token refresh failed', error, stackTrace);
      await _storage.clearTokens();
      return null;
    }
  }
}
