import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted SHA-256 hashing for the local account store.
///
/// Scope note: this exists so the dev/offline build never keeps a plaintext
/// password on device. It is **not** a substitute for server-side hashing —
/// against a real backend, passwords are sent over TLS and hashed there with a
/// memory-hard KDF (argon2/bcrypt), and this class is unused.
abstract final class PasswordHasher {
  static final Random _random = Random.secure();

  static String generateSalt([int length = 16]) {
    final List<int> bytes = List<int>.generate(
      length,
      (_) => _random.nextInt(256),
    );
    return base64Url.encode(bytes);
  }

  static String hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt::$password')).toString();

  static bool verify(String password, String salt, String expectedHash) =>
      hash(password, salt) == expectedHash;
}
