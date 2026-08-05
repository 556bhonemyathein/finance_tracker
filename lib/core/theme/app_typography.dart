import 'package:flutter/material.dart';

/// Type scale for PocketPilot, built on the bundled Plus Jakarta Sans family.
///
/// We deliberately tighten letter spacing on display/headline sizes: the 2026
/// "minimal fintech" look leans on large, tight numerals and generous
/// whitespace rather than on decoration.
abstract final class AppTypography {
  static const String fontFamily = 'PlusJakartaSans';

  static TextTheme textTheme(Brightness brightness) {
    final Color primary = brightness == Brightness.dark
        ? const Color(0xFFF3F3F7)
        : const Color(0xFF12121A);

    TextStyle style(
      double size,
      FontWeight weight, {
      double height = 1.25,
      double spacing = 0,
    }) {
      return TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: spacing,
        color: primary,
      );
    }

    return TextTheme(
      displayLarge: style(44, FontWeight.w800, spacing: -1.2),
      displayMedium: style(36, FontWeight.w800, spacing: -0.9),
      displaySmall: style(30, FontWeight.w700, spacing: -0.6),
      headlineLarge: style(28, FontWeight.w700, spacing: -0.5),
      headlineMedium: style(24, FontWeight.w700, spacing: -0.4),
      headlineSmall: style(20, FontWeight.w700, spacing: -0.2),
      titleLarge: style(18, FontWeight.w600, height: 1.3),
      titleMedium: style(16, FontWeight.w600, height: 1.35),
      titleSmall: style(14, FontWeight.w600, height: 1.35),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.5),
      bodySmall: style(12, FontWeight.w400, height: 1.45),
      labelLarge: style(14, FontWeight.w600, spacing: 0.1),
      labelMedium: style(12, FontWeight.w600, spacing: 0.2),
      labelSmall: style(11, FontWeight.w500, spacing: 0.3),
    );
  }

  /// Tabular figures for money — keeps amounts from jittering as digits change.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];
}
