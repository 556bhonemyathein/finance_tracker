import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../shared/models/app_user.dart';

/// The REST half of auth.
///
/// It does nothing but shape requests and parse responses — no caching, no
/// business rules, no error translation (the Dio interceptors already turned
/// failures into `AppException`). That single responsibility is what makes the
/// repository above it easy to reason about.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.login,
          data: <String, dynamic>{'email': email, 'password': password},
        );
    return AuthSession.fromJson(response.data!);
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.register,
          data: <String, dynamic>{
            'name': name,
            'email': email,
            'password': password,
          },
        );
    return AuthSession.fromJson(response.data!);
  }

  Future<AppUser> me() async {
    final Response<Map<String, dynamic>> response =
        await _dio.get<Map<String, dynamic>>(ApiEndpoints.me);
    return AppUser.fromJson(response.data!);
  }

  Future<AppUser> updateProfile(AppUser user) async {
    final Response<Map<String, dynamic>> response = await _dio
        .patch<Map<String, dynamic>>(ApiEndpoints.me, data: user.toJson());
    return AppUser.fromJson(response.data!);
  }

  Future<String> requestPasswordReset(String email) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.forgotPassword,
          data: <String, dynamic>{'email': email},
        );
    return response.data?['target'] as String? ?? email;
  }

  Future<bool> verifyOtp({
    required String email,
    required String code,
  }) async {
    final Response<Map<String, dynamic>> response = await _dio
        .post<Map<String, dynamic>>(
          ApiEndpoints.verifyOtp,
          data: <String, dynamic>{'email': email, 'code': code},
        );
    return response.data?['valid'] as bool? ?? true;
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => _dio.post<void>(
    ApiEndpoints.resetPassword,
    data: <String, dynamic>{
      'email': email,
      'code': code,
      'password': newPassword,
    },
  );

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => _dio.post<void>(
    ApiEndpoints.changePassword,
    data: <String, dynamic>{
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    },
  );

  Future<void> logout() => _dio.post<void>(ApiEndpoints.logout);

  Future<void> deleteAccount() => _dio.delete<void>(ApiEndpoints.deleteAccount);
}
