import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/services/password_hasher.dart';
import '../../../core/storage/entities/user_entity.dart';
import '../../../core/storage/isar_service.dart';
import '../../../shared/models/app_user.dart';

/// Account storage backed by Isar.
///
/// It plays two roles:
///   * **cache** — holds the signed-in user so the app renders instantly at
///     boot and keeps working offline;
///   * **local backend** — when `AppConfig.useLocalBackend` is on, it also
///     verifies credentials and mints tokens, so the whole app is usable with
///     no server. The auth repository decides which role applies.
class AuthLocalDataSource {
  AuthLocalDataSource(this._isar, [this._uuid = const Uuid()]);

  final IsarService _isar;
  final Uuid _uuid;

  // ── Cache role ──────────────────────────────────────────────────────────────

  Future<AppUser?> currentUser() async {
    final UserEntity? row =
        await _isar.users.filter().isCurrentEqualTo(true).findFirst();
    return row?.toDomain();
  }

  Future<void> cacheUser(AppUser user) async {
    await _isar.isar.writeTxn(() async {
      final UserEntity? existing = await _isar.users
          .filter()
          .uidEqualTo(user.id)
          .findFirst();

      // Clear the previous "current" flag so exactly one row ever owns it.
      final List<UserEntity> others = await _isar.users
          .filter()
          .isCurrentEqualTo(true)
          .findAll();
      for (final UserEntity other in others) {
        if (other.uid != user.id) {
          await _isar.users.put(other..isCurrent = false);
        }
      }

      await _isar.users.put(
        user.toEntity(
          isarId: existing?.isarId,
          passwordHash: existing?.passwordHash ?? '',
          passwordSalt: existing?.passwordSalt ?? '',
        ),
      );
    });
  }

  Future<void> clearCurrent() async {
    await _isar.isar.writeTxn(() async {
      final List<UserEntity> rows = await _isar.users
          .filter()
          .isCurrentEqualTo(true)
          .findAll();
      for (final UserEntity row in rows) {
        await _isar.users.put(row..isCurrent = false);
      }
    });
  }

  Future<void> deleteUser(String uid) async {
    await _isar.isar.writeTxn(() async {
      final UserEntity? row =
          await _isar.users.filter().uidEqualTo(uid).findFirst();
      if (row != null) await _isar.users.delete(row.isarId);
    });
  }

  // ── Local-backend role ──────────────────────────────────────────────────────

  /// Creates an account. Throws [ValidationException] if the email is taken —
  /// mirroring exactly what the REST endpoint returns, so the repository and
  /// the UI cannot tell the two backends apart.
  Future<AppUser> createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final String normalised = email.trim().toLowerCase();
    final UserEntity? existing = await _isar.users
        .filter()
        .emailEqualTo(normalised, caseSensitive: false)
        .findFirst();

    if (existing != null) {
      throw const ValidationException(
        'That email is already registered',
        fieldErrors: <String, List<String>>{
          'email': <String>['That email is already registered'],
        },
      );
    }

    final String salt = PasswordHasher.generateSalt();
    final AppUser user = AppUser(
      id: _uuid.v4(),
      name: name.trim(),
      email: normalised,
      createdAt: DateTime.now(),
    );

    await _isar.isar.writeTxn(() async {
      await _isar.users.put(
        user.toEntity(
          passwordHash: PasswordHasher.hash(password, salt),
          passwordSalt: salt,
        ),
      );
    });
    return user;
  }

  /// Verifies credentials. Throws [UnauthorizedException] on a mismatch — the
  /// same message for "no such user" and "wrong password", so the endpoint
  /// cannot be used to enumerate registered emails.
  Future<AppUser> authenticate({
    required String email,
    required String password,
  }) async {
    const UnauthorizedException wrong = UnauthorizedException(
      'Incorrect email or password',
    );

    final UserEntity? row = await _isar.users
        .filter()
        .emailEqualTo(email.trim().toLowerCase(), caseSensitive: false)
        .findFirst();

    if (row == null) throw wrong;
    if (!PasswordHasher.verify(password, row.passwordSalt, row.passwordHash)) {
      throw wrong;
    }

    await _isar.isar.writeTxn(() => _isar.users.put(row..isCurrent = true));
    return row.toDomain();
  }

  Future<bool> emailExists(String email) async {
    final UserEntity? row = await _isar.users
        .filter()
        .emailEqualTo(email.trim().toLowerCase(), caseSensitive: false)
        .findFirst();
    return row != null;
  }

  Future<void> setPassword({
    required String email,
    required String newPassword,
  }) async {
    final UserEntity? row = await _isar.users
        .filter()
        .emailEqualTo(email.trim().toLowerCase(), caseSensitive: false)
        .findFirst();
    if (row == null) throw const NotFoundException('No account for that email');

    final String salt = PasswordHasher.generateSalt();
    await _isar.isar.writeTxn(
      () => _isar.users.put(
        row
          ..passwordSalt = salt
          ..passwordHash = PasswordHasher.hash(newPassword, salt),
      ),
    );
  }

  Future<bool> verifyPassword({
    required String uid,
    required String password,
  }) async {
    final UserEntity? row =
        await _isar.users.filter().uidEqualTo(uid).findFirst();
    if (row == null) return false;
    return PasswordHasher.verify(password, row.passwordSalt, row.passwordHash);
  }
}
