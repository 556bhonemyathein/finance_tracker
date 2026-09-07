import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/models/category.dart';
import '../../../shared/models/enums.dart';

/// The starter set seeded on first launch.
///
/// An empty categories list is a dead end: the user cannot record a
/// transaction until they have built taxonomy, which is the fastest way to
/// lose someone in the first minute. Seeding sensible defaults means the app
/// is useful immediately, and every one of them stays editable.
abstract final class DefaultCategories {
  static List<Category> build({Uuid uuid = const Uuid()}) {
    final DateTime now = DateTime.now();
    int order = 0;

    Category make(
      String name,
      IconData icon,
      int color,
      CategoryKind kind,
    ) => Category(
      id: uuid.v4(),
      name: name,
      iconCodePoint: icon.codePoint,
      colorValue: color,
      kind: kind,
      isDefault: true,
      sortOrder: order++,
      createdAt: now,
      updatedAt: now,
      // Seeded rows are not "pending create": they are local defaults, and
      // pushing them at a server that already has its own would duplicate.
      syncStatus: SyncStatus.synced,
    );

    return <Category>[
      // ── Income ────────────────────────────────────────────────────────────
      make('Salary', Icons.payments_outlined, 0xFF0FA968, CategoryKind.income),
      make('Freelance', Icons.laptop_mac_outlined, 0xFF14B8A6,
          CategoryKind.income),
      make('Investments', Icons.trending_up_rounded, 0xFF0B84E0,
          CategoryKind.income),
      make('Gifts', Icons.card_giftcard_rounded, 0xFFEC4899,
          CategoryKind.income),

      // ── Expense ───────────────────────────────────────────────────────────
      make('Food & Drink', Icons.restaurant_rounded, 0xFFF97316,
          CategoryKind.expense),
      make('Groceries', Icons.local_grocery_store_outlined, 0xFF84CC16,
          CategoryKind.expense),
      make('Transport', Icons.directions_bus_filled_outlined, 0xFF5B5BF5,
          CategoryKind.expense),
      make('Housing', Icons.home_outlined, 0xFF7C4DFF, CategoryKind.expense),
      make('Bills & Utilities', Icons.receipt_long_outlined, 0xFF0EA5E9,
          CategoryKind.expense),
      make('Shopping', Icons.shopping_bag_outlined, 0xFFEC4899,
          CategoryKind.expense),
      make('Health', Icons.favorite_outline_rounded, 0xFFE5484D,
          CategoryKind.expense),
      make('Entertainment', Icons.movie_outlined, 0xFFD98A00,
          CategoryKind.expense),
      make('Education', Icons.school_outlined, 0xFF6366F1,
          CategoryKind.expense),
      make('Travel', Icons.flight_takeoff_rounded, 0xFF06B6D4,
          CategoryKind.expense),
      make('Savings', Icons.savings_outlined, 0xFF10B981, CategoryKind.both),
      make('Other', Icons.more_horiz_rounded, 0xFF64748B, CategoryKind.both),
    ];
  }
}
