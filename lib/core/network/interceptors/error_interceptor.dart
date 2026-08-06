import 'package:dio/dio.dart';

import '../../errors/app_exception.dart' as errors;

/// Converts every `DioException` into a typed [errors.AppException].
///
/// After this interceptor, no code above the network layer ever has to know
/// what Dio is — repositories catch `AppException`, and the rest of the app
/// sees only `Failure`.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: _map(err),
      ),
    );
  }

  errors.AppException _map(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const errors.TimeoutException();
      case DioExceptionType.connectionError:
        return const errors.NetworkException();
      case DioExceptionType.cancel:
        return const errors.CancelledException();
      case DioExceptionType.badCertificate:
        return const errors.NetworkException('Could not verify the server');
      case DioExceptionType.unknown:
        return errors.UnknownException(
          err.message ?? 'Unexpected network error',
          cause: err.error,
        );
      case DioExceptionType.badResponse:
        return _mapStatus(err.response);
    }
  }

  errors.AppException _mapStatus(Response<dynamic>? response) {
    final int status = response?.statusCode ?? 0;
    final Map<String, dynamic> body = switch (response?.data) {
      final Map<String, dynamic> map => map,
      _ => const <String, dynamic>{},
    };
    final String message =
        (body['message'] ?? body['error']) as String? ?? 'Request failed';

    return switch (status) {
      401 || 403 => errors.UnauthorizedException(message),
      404 => errors.NotFoundException(message),
      422 || 400 => errors.ValidationException(
        message,
        fieldErrors: _parseFieldErrors(body['errors']),
      ),
      >= 500 => errors.ServerException(message, statusCode: status),
      _ => errors.UnknownException(message),
    };
  }

  /// Accepts both `{"email": "taken"}` and `{"email": ["taken", "invalid"]}`,
  /// which are the two shapes most REST backends emit.
  Map<String, List<String>> _parseFieldErrors(Object? raw) {
    if (raw is! Map) return const <String, List<String>>{};
    return raw.map<String, List<String>>((Object? key, Object? value) {
      final List<String> messages = switch (value) {
        final List<dynamic> list => list.map((Object? v) => '$v').toList(),
        _ => <String>['$value'],
      };
      return MapEntry<String, List<String>>('$key', messages);
    });
  }
}
