import '../../../core/utils/result.dart';
import '../../../shared/models/app_user.dart';

/// The auth contract the presentation layer depends on.
///
/// Declaring the interface in `domain/` and the implementation in `data/` is
/// the dependency-inversion half of clean architecture: the notifier depends
/// on this abstraction, so swapping the local simulator for a live REST
/// backend is a one-line change in the provider — no UI edits at all.
abstract interface class AuthRepository {
  /// The session restored at boot, or `null` when nobody is signed in.
  Future<Result<AuthSession?>> restoreSession();

  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  });

  /// Starts password recovery; returns the delivery target for the UI to echo.
  Future<Result<String>> requestPasswordReset(String email);

  Future<Result<bool>> verifyOtp({required String email, required String code});

  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<AppUser>> updateProfile(AppUser user);

  Future<Result<void>> logout();

  /// Wipes the account and every local row belonging to it.
  Future<Result<void>> deleteAccount();

  /// Email remembered for the login form, when "Remember me" was ticked.
  Future<String?> rememberedEmail();
}
