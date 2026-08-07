/// Bundled asset paths.
///
/// Referencing assets through constants rather than string literals means a
/// renamed or removed file breaks at the call site instead of throwing at
/// runtime on the one screen nobody opened before shipping.
abstract final class AppAssets {
  /// The app mark — the same artwork as the launcher icon, so the splash and
  /// the home-screen icon are visibly the same product.
  static const String logo = 'assets/images/app_icon.png';
}
