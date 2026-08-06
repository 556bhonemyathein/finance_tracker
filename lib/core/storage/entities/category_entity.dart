import 'package:isar_community/isar.dart';

import '../../../shared/models/category.dart';
import '../../../shared/models/enums.dart';

part 'category_entity.g.dart';

/// Isar row for a category.
@collection
class CategoryEntity {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uid;

  @Index(caseSensitive: false)
  late String name;

  late int iconCodePoint;

  late int colorValue;

  @Enumerated(EnumType.name)
  late CategoryKind kind;

  late bool isDefault;

  late int sortOrder;

  late DateTime createdAt;

  late DateTime updatedAt;

  @Index()
  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;

  @Index()
  bool isDeleted = false;

  Category toDomain() => Category(
    id: uid,
    name: name,
    iconCodePoint: iconCodePoint,
    colorValue: colorValue,
    kind: kind,
    isDefault: isDefault,
    sortOrder: sortOrder,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: syncStatus,
  );
}

extension CategoryEntityX on Category {
  CategoryEntity toEntity({int? isarId}) {
    final DateTime now = DateTime.now();
    return CategoryEntity()
      ..isarId = isarId ?? Isar.autoIncrement
      ..uid = id
      ..name = name
      ..iconCodePoint = iconCodePoint
      ..colorValue = colorValue
      ..kind = kind
      ..isDefault = isDefault
      ..sortOrder = sortOrder
      ..createdAt = createdAt ?? now
      ..updatedAt = updatedAt ?? now
      ..syncStatus = syncStatus
      ..isDeleted = syncStatus == SyncStatus.pendingDelete;
  }
}
