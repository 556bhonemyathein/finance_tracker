import 'app_flavor.dart';

/// Immutable, environment-specific configuration.
///
/// This is the single source of truth for "what changes between builds":
/// base URLs, timeouts, logging. Everything else in the app depends on the
/// abstraction rather than on compile-time constants, which keeps the code
/// testable — a test can install a config pointing at a mock server.
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.enableCrashReporting,
    this.connectTimeout = const Duration(seconds: 20),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enableCrashReporting;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  bool get isProd => flavor.isProd;

  // ── Factories ───────────────────────────────────────────────────────────────

  static const AppConfig dev = AppConfig(
    flavor: AppFlavor.dev,
    appName: 'PocketPilot Dev',
    apiBaseUrl: 'https://dev.api.pocketpilot.app/v1',
    enableLogging: true,
    enableCrashReporting: false,
  );

  static const AppConfig staging = AppConfig(
    flavor: AppFlavor.staging,
    appName: 'PocketPilot Staging',
    apiBaseUrl: 'https://staging.api.pocketpilot.app/v1',
    enableLogging: true,
    enableCrashReporting: true,
  );

  static const AppConfig prod = AppConfig(
    flavor: AppFlavor.prod,
    appName: 'PocketPilot',
    apiBaseUrl: 'https://api.pocketpilot.app/v1',
    enableLogging: false,
    enableCrashReporting: true,
  );

  /// Resolves the config from the `--dart-define=FLAVOR=...` build argument,
  /// defaulting to [dev] so `flutter run` works with no extra ceremony.
  static AppConfig fromEnvironment() {
    const raw = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
    return switch (raw.toLowerCase()) {
      'prod' || 'production' => prod,
      'staging' || 'stg' => staging,
      _ => dev,
    };
  }
}
