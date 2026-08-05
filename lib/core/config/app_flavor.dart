/// Build flavors supported by PocketPilot.
///
/// The flavor is injected once at start-up (see `main.dart`) and read through
/// [AppConfig]. Keeping it in an enum — rather than sprinkling `kDebugMode`
/// checks around the codebase — means behaviour differences stay declarative
/// and testable.
enum AppFlavor {
  dev('DEV'),
  staging('STAGING'),
  prod('PROD');

  const AppFlavor(this.label);

  /// Short label rendered in the debug banner of non-production builds.
  final String label;

  bool get isProd => this == AppFlavor.prod;
}
