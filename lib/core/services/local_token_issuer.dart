import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Mints JWT-shaped tokens for the local backend.
///
/// The tokens are real JWTs structurally (header.payload.signature, base64url,
/// `exp`/`sub` claims) so the app exercises the same storage, expiry and
/// refresh code paths it will use against the production API. The signature is
/// **not** trustworthy — the device signs its own tokens — which is precisely
/// why this is confined to `useLocalBackend` builds.
abstract final class LocalTokenIssuer {
  static const String _devSecret = 'pocketpilot-local-backend';
  static final Random _random = Random.secure();

  static const Duration accessTokenTtl = Duration(minutes: 30);
  static const Duration refreshTokenTtl = Duration(days: 30);

  static ({String accessToken, String refreshToken, DateTime expiresAt}) issue(
    String userId,
  ) {
    final DateTime now = DateTime.now();
    final DateTime expiresAt = now.add(accessTokenTtl);
    return (
      accessToken: _sign(userId, expiresAt, 'access'),
      refreshToken: _sign(userId, now.add(refreshTokenTtl), 'refresh'),
      expiresAt: expiresAt,
    );
  }

  static String _sign(String subject, DateTime expiry, String type) {
    final String header = _b64(
      jsonEncode(<String, String>{'alg': 'HS256', 'typ': 'JWT'}),
    );
    final String payload = _b64(
      jsonEncode(<String, Object>{
        'sub': subject,
        'typ': type,
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': expiry.millisecondsSinceEpoch ~/ 1000,
        'jti': _random.nextInt(1 << 32).toString(),
      }),
    );
    final String signature = base64Url
        .encode(
          Hmac(sha256, utf8.encode(_devSecret))
              .convert(utf8.encode('$header.$payload'))
              .bytes,
        )
        .replaceAll('=', '');
    return '$header.$payload.$signature';
  }

  static String _b64(String raw) =>
      base64Url.encode(utf8.encode(raw)).replaceAll('=', '');

  /// Six-digit one-time code for the password-reset flow.
  static String issueOtp() =>
      (_random.nextInt(900000) + 100000).toString();
}
