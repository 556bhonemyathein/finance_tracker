/// Spacing, radius and elevation scale.
///
/// A single numeric scale is what separates a design *system* from a pile of
/// magic numbers. Every padding/gap in the app should come from here.
abstract final class AppSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  /// Default horizontal page gutter.
  static const double page = 20;
}

abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 999;
}

/// Responsive breakpoints (logical pixels). Used by `context.formFactor`.
abstract final class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}
