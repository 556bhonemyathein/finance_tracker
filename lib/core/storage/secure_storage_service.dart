import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/storage_keys.dart';
import '../errors/app_exception.dart';
import '../utils/app_logger.dart';

/// Encrypted key–value store for credentials.
///
/// Tokens must never sit in `SharedPreferences`: on Android that is a
/// world-readable-by-root XML file, and on iOS it is an unprotected plist.
/// This wrapper pins the platform options (Android EncryptedSharedPreferences,
/// iOS Keychain `first_unlock`) in one place.
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
    : _storage =
          storage ??
          const FlutterSecureStorage(
            // Android encryption is handled by the plugin's own ciphers since
            // v10 (Jetpack Security was deprecated by Google), so no Android
            // option is needed here.
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (error, stackTrace) {
      // A corrupt keystore should log the user out, not crash the app.
      AppLogger.w('Secure read failed for $key', error, stackTrace);
      return null;
    }
  }

  Future<void> write(String key, String? value) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } catch (error, stackTrace) {
      AppLogger.e('Secure write failed for $key', error, stackTrace);
      throw CacheException('Could not persist credentials', cause: error);
    }
  }

  Future<void> delete(String key) => write(key, null);

  // ── Token helpers ───────────────────────────────────────────────────────────

  Future<String?> get accessToken => read(StorageKeys.accessToken);

  Future<String?> get refreshToken => read(StorageKeys.refreshToken);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await write(StorageKeys.accessToken, accessToken);
    await write(StorageKeys.refreshToken, refreshToken);
  }

  Future<void> clearTokens() async {
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
  }
}
