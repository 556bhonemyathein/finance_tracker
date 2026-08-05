import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Thin façade over `package:logger`.
///
/// Going through a façade (instead of calling `print` or `Logger()` directly)
/// gives us two things a production app needs: log output is disabled in
/// release builds, and there is exactly one seam to forward errors to
/// Crashlytics once crash reporting is wired up.
abstract final class AppLogger {
  static Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 100,
      colors: true,
      printEmojis: true,
    ),
    level: kReleaseMode ? Level.off : Level.debug,
  );

  /// Enables/disables output at runtime (driven by `AppConfig.enableLogging`).
  static void configure({required bool enabled}) {
    Logger.level = enabled ? Level.debug : Level.off;
    _logger = Logger(
      printer: PrettyPrinter(methodCount: 0, lineLength: 100),
      level: enabled ? Level.debug : Level.off,
    );
  }

  static void d(Object? message) => _logger.d(message);

  static void i(Object? message) => _logger.i(message);

  static void w(Object? message, [Object? error, StackTrace? stackTrace]) =>
      _logger.w(message, error: error, stackTrace: stackTrace);

  static void e(Object? message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    // TODO(crashlytics): forward to FirebaseCrashlytics.recordError here once
    // the Firebase step lands, so every logged error becomes a non-fatal.
  }
}
