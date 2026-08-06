/// Route paths and names in one place.
///
/// Every `context.goNamed(...)` call site references these constants, so a
/// path can be changed without hunting for string literals — and a typo
/// becomes a compile error instead of a blank screen.
abstract final class AppRoutes {
  // ── Auth ────────────────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';

  // ── Shell tabs ──────────────────────────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String reports = '/reports';
  static const String profile = '/profile';

  // ── Pushed routes ───────────────────────────────────────────────────────────
  static const String transactionForm = 'transaction-form';
  static const String transactionDetail = 'transaction-detail';
  static const String search = 'search';
  static const String categories = 'categories';
  static const String categoryForm = 'category-form';
  static const String settings = 'settings';
  static const String editProfile = 'edit-profile';
  static const String changePassword = 'change-password';
  static const String about = 'about';

  /// Routes reachable without a session. Everything else redirects to login.
  static const Set<String> publicRoutes = <String>{
    splash,
    onboarding,
    login,
    register,
    forgotPassword,
    otp,
    resetPassword,
  };
}
