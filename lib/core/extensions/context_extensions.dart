import 'package:flutter/material.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme_extension.dart';

/// Screen size buckets driving the adaptive layout.
enum FormFactor { mobile, tablet, desktop }

/// Ergonomic shortcuts on [BuildContext].
///
/// `Theme.of(context).colorScheme.primary` appears hundreds of times in a real
/// app; `context.colors.primary` says the same thing with far less noise, and
/// keeps every widget reading from the theme instead of hard-coded values.
extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  /// Domain colours (income/expense/glass…) registered as a [ThemeExtension].
  AppFinanceColors get finance =>
      Theme.of(this).extension<AppFinanceColors>() ?? AppFinanceColors.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  MediaQueryData get mq => MediaQuery.of(this);

  Size get screenSize => MediaQuery.sizeOf(this);

  double get screenWidth => MediaQuery.sizeOf(this).width;

  double get screenHeight => MediaQuery.sizeOf(this).height;

  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  /// Height of the on-screen keyboard, 0 when hidden.
  double get keyboardInset => MediaQuery.viewInsetsOf(this).bottom;

  FormFactor get formFactor {
    final double w = screenWidth;
    if (w >= AppBreakpoints.tablet) return FormFactor.desktop;
    if (w >= AppBreakpoints.mobile) return FormFactor.tablet;
    return FormFactor.mobile;
  }

  bool get isMobile => formFactor == FormFactor.mobile;

  bool get isTablet => formFactor == FormFactor.tablet;

  bool get isDesktop => formFactor == FormFactor.desktop;

  /// Picks a value per form factor, falling back to the smaller bucket.
  T responsive<T>({required T mobile, T? tablet, T? desktop}) {
    return switch (formFactor) {
      FormFactor.desktop => desktop ?? tablet ?? mobile,
      FormFactor.tablet => tablet ?? mobile,
      FormFactor.mobile => mobile,
    };
  }

  /// Content width capped on large screens so lines stay readable.
  double get contentMaxWidth => responsive(
    mobile: double.infinity,
    tablet: 720,
    desktop: 960,
  );

  void unfocus() => FocusScope.of(this).unfocus();
}
