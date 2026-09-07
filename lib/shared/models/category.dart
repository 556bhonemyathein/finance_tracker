import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'category_icons.dart';
import 'enums.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Domain model for a spending/earning category.
///
/// Icon and colour are stored as primitives (`int`) rather than as Flutter
/// types so the model stays serialisable and free of UI dependencies; the
/// [icon] and [color] getters do the conversion at the edge.
@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    required int iconCodePoint,
    required int colorValue,
    @Default(CategoryKind.both) CategoryKind kind,
    /// Seeded categories cannot be deleted — only hidden — so a user can never
    /// end up with transactions pointing at nothing.
    @Default(false) bool isDefault,
    @Default(0) int sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(SyncStatus.pendingCreate) SyncStatus syncStatus,
  }) = _Category;

  const Category._();

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  /// Resolved against [CategoryIcons] rather than built with `IconData(...)`:
  /// a runtime invocation would defeat icon tree-shaking in release builds.
  IconData get icon => CategoryIcons.resolve(iconCodePoint);

  Color get color => Color(colorValue);

  /// Placeholder used when a transaction references a deleted category.
  static const Category unknown = Category(
    id: '__unknown__',
    name: 'Uncategorised',
    iconCodePoint: 0xe332, // CategoryIcons.fallback (Icons.help_outline)
    colorValue: 0xFF64748B,
    isDefault: true,
    syncStatus: SyncStatus.synced,
  );
}
