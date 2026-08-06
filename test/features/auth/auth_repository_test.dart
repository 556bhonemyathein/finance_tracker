import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/errors/app_exception.dart';
import 'package:finance_tracker/core/errors/failure.dart';
import 'package:finance_tracker/core/storage/preferences_service.dart';
import 'package:finance_tracker/core/storage/secure_storage_service.dart';
import 'package:finance_tracker/core/utils/result.dart';
import 'package:finance_tracker/features/auth/data/auth_local_datasource.dart';
import 'package:finance_tracker/features/auth/data/auth_remote_datasource.dart';
import 'package:finance_tracker/features/auth/data/auth_repository_impl.dart';
import 'package:finance_tracker/shared/models/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockLocal extends Mock implements AuthLocalDataSource {}

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockSecureStorage extends Mock implements SecureStorageService {}

/// Repository tests.
///
/// The repository is where the interesting decisions live — which data source
/// answers, what happens when the network fails, how exceptions become
/// failures. Mocking both data sources lets those decisions be tested without
/// a database or a server.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockLocal local;
  late _MockRemote remote;
  late _MockSecureStorage secure;
  late PreferencesService preferences;

  final AppUser user = AppUser(
    id: 'user-1',
    name: 'Ada Lovelace',
    email: 'ada@example.com',
    createdAt: DateTime(2026),
  );

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    preferences = await PreferencesService.create();

    local = _MockLocal();
    remote = _MockRemote();
    secure = _MockSecureStorage();

    when(
      () => secure.saveTokens(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(() => secure.clearTokens()).thenAnswer((_) async {});
    when(() => secure.write(any(), any())).thenAnswer((_) async {});
    when(() => secure.delete(any())).thenAnswer((_) async {});
    when(() => local.cacheUser(any())).thenAnswer((_) async {});
    when(() => local.clearCurrent()).thenAnswer((_) async {});
  });

  AuthRepositoryImpl buildRepository({required bool useLocalBackend}) {
    return AuthRepositoryImpl(
      local: local,
      remote: remote,
      secureStorage: secure,
      preferences: preferences,
      config: useLocalBackend ? AppConfig.dev : AppConfig.prod,
    );
  }

  group('login (local backend)', () {
    test('returns a session and persists the tokens', () async {
      when(
        () => local.authenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);

      final Result<AuthSession> result = await buildRepository(
        useLocalBackend: true,
      ).login(
        email: 'ada@example.com',
        password: 'passw0rd',
        rememberMe: true,
      );

      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull?.user.email, 'ada@example.com');
      expect(result.dataOrNull?.tokens.accessToken, isNotEmpty);

      verify(
        () => secure.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      ).called(1);
      verify(() => local.cacheUser(any())).called(1);
    });

    test('maps bad credentials to UnauthorizedFailure', () async {
      when(
        () => local.authenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const UnauthorizedException('Incorrect email or password'));

      final Result<AuthSession> result = await buildRepository(
        useLocalBackend: true,
      ).login(email: 'ada@example.com', password: 'wrong', rememberMe: true);

      expect(result.failureOrNull, isA<UnauthorizedFailure>());
      // A failed login must never leave tokens behind.
      verifyNever(
        () => secure.saveTokens(
          accessToken: any(named: 'accessToken'),
          refreshToken: any(named: 'refreshToken'),
        ),
      );
    });

    test('remembers the email only when asked', () async {
      when(
        () => local.authenticate(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => user);

      await buildRepository(useLocalBackend: true).login(
        email: 'ada@example.com',
        password: 'passw0rd',
        rememberMe: false,
      );

      // Writing null is how the remembered email is cleared.
      verify(() => secure.write(any(), null)).called(1);
      expect(preferences.rememberMe, isFalse);
    });
  });

  group('register (local backend)', () {
    test('propagates a duplicate email as a ValidationFailure with fields', () async {
      when(
        () => local.createAccount(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ValidationException(
          'That email is already registered',
          fieldErrors: <String, List<String>>{
            'email': <String>['That email is already registered'],
          },
        ),
      );

      final Result<AuthSession> result = await buildRepository(
        useLocalBackend: true,
      ).register(
        name: 'Ada',
        email: 'ada@example.com',
        password: 'passw0rd',
      );

      final Failure? failure = result.failureOrNull;
      expect(failure, isA<ValidationFailure>());
      expect(
        (failure! as ValidationFailure).errorFor('email'),
        'That email is already registered',
      );
    });
  });

  group('restoreSession', () {
    test('returns null when there is no token', () async {
      when(() => secure.accessToken).thenAnswer((_) async => null);
      when(() => local.currentUser()).thenAnswer((_) async => user);

      final Result<AuthSession?> result = await buildRepository(
        useLocalBackend: true,
      ).restoreSession();

      expect(result.dataOrNull, isNull);
    });

    test('returns null when there is no cached user', () async {
      when(() => secure.accessToken).thenAnswer((_) async => 'token');
      when(() => local.currentUser()).thenAnswer((_) async => null);

      final Result<AuthSession?> result = await buildRepository(
        useLocalBackend: true,
      ).restoreSession();

      expect(result.dataOrNull, isNull);
    });

    test('restores a session when both halves are present', () async {
      when(() => secure.accessToken).thenAnswer((_) async => 'token');
      when(() => secure.refreshToken).thenAnswer((_) async => 'refresh');
      when(() => local.currentUser()).thenAnswer((_) async => user);

      final Result<AuthSession?> result = await buildRepository(
        useLocalBackend: true,
      ).restoreSession();

      expect(result.dataOrNull?.user.id, 'user-1');
      expect(result.dataOrNull?.tokens.accessToken, 'token');
    });
  });

  group('logout', () {
    test('clears local state even when the remote call fails', () async {
      when(() => remote.logout()).thenThrow(const NetworkException());

      final Result<void> result = await buildRepository(
        useLocalBackend: false,
      ).logout();

      // The user must never be trapped in a signed-in state by a dead network.
      expect(result.isSuccess, isTrue);
      verify(() => secure.clearTokens()).called(1);
      verify(() => local.clearCurrent()).called(1);
    });
  });

  group('updateProfile', () {
    test('writes locally first and survives a failed remote sync', () async {
      when(() => remote.updateProfile(any())).thenThrow(
        const NetworkException(),
      );

      final Result<AppUser> result = await buildRepository(
        useLocalBackend: false,
      ).updateProfile(user.copyWith(name: 'Ada L.'));

      // The edit is kept: discarding the user's typing on a network blip
      // would be worse than a deferred sync.
      expect(result.dataOrNull?.name, 'Ada L.');
      verify(() => local.cacheUser(any())).called(1);
    });
  });

  group('password reset (local backend)', () {
    test('rejects an unknown email', () async {
      when(() => local.emailExists(any())).thenAnswer((_) async => false);

      final Result<String> result = await buildRepository(
        useLocalBackend: true,
      ).requestPasswordReset('nobody@example.com');

      expect(result.failureOrNull, isA<NotFoundFailure>());
    });

    test('issues a six-digit code that then verifies', () async {
      when(() => local.emailExists(any())).thenAnswer((_) async => true);

      final AuthRepositoryImpl repository = buildRepository(
        useLocalBackend: true,
      );
      final Result<String> issued = await repository.requestPasswordReset(
        'ada@example.com',
      );

      final String code = issued.dataOrNull!;
      expect(code, hasLength(6));

      final Result<bool> verified = await repository.verifyOtp(
        email: 'ada@example.com',
        code: code,
      );
      expect(verified.dataOrNull, isTrue);
    });

    test('rejects a wrong code', () async {
      when(() => local.emailExists(any())).thenAnswer((_) async => true);

      final AuthRepositoryImpl repository = buildRepository(
        useLocalBackend: true,
      );
      await repository.requestPasswordReset('ada@example.com');

      final Result<bool> verified = await repository.verifyOtp(
        email: 'ada@example.com',
        code: '000000',
      );
      expect(verified.failureOrNull, isA<ValidationFailure>());
    });
  });
}
