import '../../../core/config/app_config.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/local_token_issuer.dart';
import '../../../core/storage/preferences_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_local_datasource.dart';
import 'auth_remote_datasource.dart';

/// Decides, per call, whether auth is satisfied locally or over REST.
///
/// This is the repository pattern doing its actual job: the notifier above
/// asks for "a session"; whether that came from Isar, from the API, or from a
/// cached row after a failed network call is a decision made here and nowhere
/// else.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthLocalDataSource local,
    required AuthRemoteDataSource remote,
    required SecureStorageService secureStorage,
    required PreferencesService preferences,
    required AppConfig config,
  }) : _local = local,
       _remote = remote,
       _secure = secureStorage,
       _prefs = preferences,
       _config = config;

  final AuthLocalDataSource _local;
  final AuthRemoteDataSource _remote;
  final SecureStorageService _secure;
  final PreferencesService _prefs;
  final AppConfig _config;

  /// Outstanding password-reset codes, keyed by email. In-memory by design:
  /// a real backend owns this state, and it must not survive a restart.
  final Map<String, String> _pendingOtps = <String, String>{};

  bool get _isLocal => _config.useLocalBackend;

  @override
  Future<Result<AuthSession?>> restoreSession() => guard(() async {
    final String? access = await _secure.accessToken;
    final AppUser? cached = await _local.currentUser();

    // Auto-login needs both halves: a token to authorise calls and a cached
    // user to render the first frame without a spinner.
    if (access == null || cached == null) return null;

    final tokens = LocalTokenIssuer.issue(cached.id);
    return AuthSession(
      user: cached,
      tokens: AuthTokens(
        accessToken: access,
        refreshToken: await _secure.refreshToken ?? tokens.refreshToken,
        // The stored access token's real expiry lives in its `exp` claim; the
        // interceptor refreshes on 401 regardless, so an optimistic value is
        // safe here.
        expiresAt: DateTime.now().add(LocalTokenIssuer.accessTokenTtl),
      ),
    );
  });

  @override
  Future<Result<AuthSession>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) => guard(() async {
    final AuthSession session = _isLocal
        ? await _loginLocally(email: email, password: password)
        : await _remote.login(email: email, password: password);

    await _persistSession(session, rememberMe: rememberMe);
    return session;
  });

  Future<AuthSession> _loginLocally({
    required String email,
    required String password,
  }) async {
    final AppUser user = await _local.authenticate(
      email: email,
      password: password,
    );
    final tokens = LocalTokenIssuer.issue(user.id);
    return AuthSession(
      user: user,
      tokens: AuthTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiresAt: tokens.expiresAt,
      ),
    );
  }

  @override
  Future<Result<AuthSession>> register({
    required String name,
    required String email,
    required String password,
  }) => guard(() async {
    final AuthSession session;
    if (_isLocal) {
      final AppUser user = await _local.createAccount(
        name: name,
        email: email,
        password: password,
      );
      final tokens = LocalTokenIssuer.issue(user.id);
      session = AuthSession(
        user: user,
        tokens: AuthTokens(
          accessToken: tokens.accessToken,
          refreshToken: tokens.refreshToken,
          expiresAt: tokens.expiresAt,
        ),
      );
    } else {
      session = await _remote.register(
        name: name,
        email: email,
        password: password,
      );
    }

    await _persistSession(session, rememberMe: true);
    return session;
  });

  @override
  Future<Result<String>> requestPasswordReset(String email) => guard(() async {
    if (!_isLocal) return _remote.requestPasswordReset(email);

    if (!await _local.emailExists(email)) {
      throw const NotFoundException('No account is registered with that email');
    }
    final String code = LocalTokenIssuer.issueOtp();
    _pendingOtps[email.trim().toLowerCase()] = code;

    // A real backend emails this. The local one logs it and the OTP screen
    // surfaces it, so the flow is genuinely completable in a demo build.
    AppLogger.i('Local backend OTP for $email: $code');
    return code;
  });

  @override
  Future<Result<bool>> verifyOtp({
    required String email,
    required String code,
  }) => guard(() async {
    if (!_isLocal) return _remote.verifyOtp(email: email, code: code);

    final String? expected = _pendingOtps[email.trim().toLowerCase()];
    if (expected == null) {
      throw const ValidationException('Request a new code to continue');
    }
    if (expected != code.trim()) {
      throw const ValidationException(
        'That code is not correct',
        fieldErrors: <String, List<String>>{
          'code': <String>['That code is not correct'],
        },
      );
    }
    return true;
  });

  @override
  Future<Result<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) => guard(() async {
    if (!_isLocal) {
      return _remote.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    }

    final Result<bool> verified = await verifyOtp(email: email, code: code);
    if (verified.isFailure) throw verified.failureOrNull!;

    await _local.setPassword(email: email, newPassword: newPassword);
    _pendingOtps.remove(email.trim().toLowerCase());
  });

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) => guard(() async {
    if (!_isLocal) {
      return _remote.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    }

    final AppUser? user = await _local.currentUser();
    if (user == null) throw const UnauthorizedException();

    final bool ok = await _local.verifyPassword(
      uid: user.id,
      password: currentPassword,
    );
    if (!ok) {
      throw const ValidationException(
        'Your current password is not correct',
        fieldErrors: <String, List<String>>{
          'currentPassword': <String>['Your current password is not correct'],
        },
      );
    }
    await _local.setPassword(email: user.email, newPassword: newPassword);
  });

  @override
  Future<Result<AppUser>> updateProfile(AppUser user) => guard(() async {
    // Offline-first: the local copy is written first so the UI updates
    // immediately, then the server is told. A failed call leaves the local
    // edit intact rather than discarding the user's work.
    await _local.cacheUser(user);
    if (!_isLocal) {
      try {
        final AppUser fresh = await _remote.updateProfile(user);
        await _local.cacheUser(fresh);
        return fresh;
      } on AppException catch (error) {
        AppLogger.w('Profile sync deferred: ${error.message}');
      }
    }
    return user;
  });

  @override
  Future<Result<void>> logout() => guard(() async {
    if (!_isLocal) {
      try {
        await _remote.logout();
      } on AppException catch (error) {
        // Never block a logout on the network — the local session must go
        // regardless, or the user is trapped in a broken state.
        AppLogger.w('Remote logout failed: ${error.message}');
      }
    }
    await _secure.clearTokens();
    await _local.clearCurrent();
  });

  @override
  Future<Result<void>> deleteAccount() => guard(() async {
    final AppUser? user = await _local.currentUser();
    if (!_isLocal) {
      await _remote.deleteAccount();
    }
    if (user != null) await _local.deleteUser(user.id);
    await _secure.clearTokens();
    await _secure.delete(StorageKeys.rememberedEmail);
  });

  @override
  Future<String?> rememberedEmail() async =>
      _prefs.rememberMe ? _secure.read(StorageKeys.rememberedEmail) : null;

  Future<void> _persistSession(
    AuthSession session, {
    required bool rememberMe,
  }) async {
    await _secure.saveTokens(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );
    await _local.cacheUser(session.user);
    await _prefs.setRememberMe(value: rememberMe);
    await _secure.write(
      StorageKeys.rememberedEmail,
      rememberMe ? session.user.email : null,
    );
  }
}
