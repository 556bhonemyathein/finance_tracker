import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Domain colours that Material 3's `ColorScheme` has no slot for.
///
/// Income/expense/transfer are *semantic* to a finance app, so they belong in
/// the theme rather than being hard-coded in widgets. Shipping them as a
/// [ThemeExtension] means `Theme.of(context).extension<AppFinanceColors>()`
/// resolves correctly in light mode, dark mode and during theme lerp
/// animations.
@immutable
class AppFinanceColors extends ThemeExtension<AppFinanceColors> {
  const AppFinanceColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.savings,
    required this.glass,
    required this.glassBorder,
    required this.balanceGradient,
  });

  final Color income;
  final Color expense;
  final Color transfer;
  final Color savings;

  /// Fill for frosted panels (used behind a `BackdropFilter`).
  final Color glass;

  /// Hairline border that gives a glass panel its edge definition.
  final Color glassBorder;

  final List<Color> balanceGradient;

  static const AppFinanceColors light = AppFinanceColors(
    income: AppColors.incomeLight,
    expense: AppColors.expenseLight,
    transfer: AppColors.transferLight,
    savings: AppColors.savingsLight,
    glass: AppColors.glassLight,
    glassBorder: AppColors.glassBorderLight,
    balanceGradient: AppColors.balanceGradientLight,
  );

  static const AppFinanceColors dark = AppFinanceColors(
    income: AppColors.incomeDark,
    expense: AppColors.expenseDark,
    transfer: AppColors.transferDark,
    savings: AppColors.savingsDark,
    glass: AppColors.glassDark,
    glassBorder: AppColors.glassBorderDark,
    balanceGradient: AppColors.balanceGradientDark,
  );

  @override
  AppFinanceColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? savings,
    Color? glass,
    Color? glassBorder,
    List<Color>? balanceGradient,
  }) {
    return AppFinanceColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      savings: savings ?? this.savings,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      balanceGradient: balanceGradient ?? this.balanceGradient,
    );
  }

  @override
  AppFinanceColors lerp(covariant AppFinanceColors? other, double t) {
    if (other == null) return this;
    return AppFinanceColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      savings: Color.lerp(savings, other.savings, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      balanceGradient: [
        for (var i = 0; i < balanceGradient.length; i++)
          Color.lerp(balanceGradient[i], other.balanceGradient[i], t)!,
      ],
    );
  }
}
