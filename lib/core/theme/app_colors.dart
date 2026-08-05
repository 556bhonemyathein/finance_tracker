import 'package:flutter/material.dart';

/// Raw palette.
///
/// These values are *only* consumed by `AppTheme` and the theme extensions.
/// Widgets must never reference [AppColors] directly — they read from
/// `Theme.of(context).colorScheme` / `context.finance` so that light, dark and
/// any future high-contrast theme keep working for free.
abstract final class AppColors {
  // ── Brand ───────────────────────────────────────────────────────────────────
  static const Color seed = Color(0xFF5B5BF5);
  static const Color brandViolet = Color(0xFF7C4DFF);
  static const Color brandIndigo = Color(0xFF5B5BF5);
  static const Color brandCyan = Color(0xFF38BDF8);

  // ── Semantic finance colours (light) ────────────────────────────────────────
  static const Color incomeLight = Color(0xFF0FA968);
  static const Color expenseLight = Color(0xFFE5484D);
  static const Color transferLight = Color(0xFF0B84E0);
  static const Color savingsLight = Color(0xFFD98A00);

  // ── Semantic finance colours (dark) ─────────────────────────────────────────
  static const Color incomeDark = Color(0xFF3DDC97);
  static const Color expenseDark = Color(0xFFFF7A8A);
  static const Color transferDark = Color(0xFF5AC8FA);
  static const Color savingsDark = Color(0xFFFFC65C);

  // ── Neutral surfaces ────────────────────────────────────────────────────────
  static const Color scaffoldLight = Color(0xFFF6F6FB);
  static const Color scaffoldDark = Color(0xFF0B0B12);
  static const Color surfaceDark = Color(0xFF14141D);
  static const Color surfaceElevatedDark = Color(0xFF1C1C28);

  // ── Glassmorphism ───────────────────────────────────────────────────────────
  static const Color glassLight = Color(0x99FFFFFF);
  static const Color glassBorderLight = Color(0x33FFFFFF);
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassBorderDark = Color(0x24FFFFFF);

  // ── Gradients used by hero cards / charts ───────────────────────────────────
  static const List<Color> balanceGradientLight = [
    Color(0xFF5B5BF5),
    Color(0xFF9B5BF5),
  ];
  static const List<Color> balanceGradientDark = [
    Color(0xFF4B47D6),
    Color(0xFF7C3FD1),
  ];

  /// Deterministic palette offered by the category colour picker.
  static const List<Color> categorySwatches = [
    Color(0xFF5B5BF5),
    Color(0xFF7C4DFF),
    Color(0xFFE5484D),
    Color(0xFFFF6B6B),
    Color(0xFFF97316),
    Color(0xFFD98A00),
    Color(0xFF0FA968),
    Color(0xFF14B8A6),
    Color(0xFF0B84E0),
    Color(0xFF38BDF8),
    Color(0xFFEC4899),
    Color(0xFF64748B),
  ];
}
