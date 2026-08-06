import 'package:isar_community/isar.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/storage/entities/category_entity.dart';
import '../../../core/storage/entities/transaction_entity.dart';
import '../../../core/storage/isar_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/enums.dart';
import '../domain/category_repository.dart';
import 'default_categories.dart';

/// Offline-first category store.
///
/// Isar is the source of truth. Writes always land locally first and are
/// marked pending; the sync engine pushes them later. This ordering is what
/// makes the app feel instant and work on a plane.
class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._isar);

  final IsarService _isar;

  @override
  Stream<List<Category>> watchAll() async* {
    Future<List<Category>> read() async {
      final List<CategoryEntity> rows = await _isar.categories
          .filter()
          .isDeletedEqualTo(false)
          .sortBySortOrder()
          .thenByName()
          .findAll();
      return rows.map((CategoryEntity e) => e.toDomain()).toList();
    }

    yield await read();
    // `fireImmediately: false` because we just emitted the current value.
    await for (final void _ in _isar.categories.watchLazy()) {
      yield await read();
    }
  }

  @override
  Future<Result<List<Category>>> getAll() => guard(() async {
    final List<CategoryEntity> rows = await _isar.categories
        .filter()
        .isDeletedEqualTo(false)
        .sortBySortOrder()
        .findAll();
    return rows.map((CategoryEntity e) => e.toDomain()).toList();
  });

  @override
  Future<Result<Category>> create(Category category) => guard(() async {
    await _assertNameIsFree(category);

    final Category toSave = category.copyWith(
      createdAt: category.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pendingCreate,
    );
    await _isar.isar.writeTxn(() => _isar.categories.put(toSave.toEntity()));
    return toSave;
  });

  @override
  Future<Result<Category>> update(Category category) => guard(() async {
    final CategoryEntity? existing = await _isar.categories
        .filter()
        .uidEqualTo(category.id)
        .findFirst();
    if (existing == null) throw const NotFoundException('Category not found');

    await _assertNameIsFree(category);

    final Category toSave = category.copyWith(
      updatedAt: DateTime.now(),
      // A row that was never pushed stays `pendingCreate`; one the server
      // already knows about becomes `pendingUpdate`. Getting this wrong is how
      // sync engines create duplicates.
      syncStatus: existing.syncStatus == SyncStatus.pendingCreate
          ? SyncStatus.pendingCreate
          : SyncStatus.pendingUpdate,
    );
    await _isar.isar.writeTxn(
      () => _isar.categories.put(toSave.toEntity(isarId: existing.isarId)),
    );
    return toSave;
  });

  @override
  Future<Result<void>> delete(String id, {String? reassignTo}) =>
      guard(() async {
        final CategoryEntity? row =
            await _isar.categories.filter().uidEqualTo(id).findFirst();
        if (row == null) throw const NotFoundException('Category not found');

        if (row.isDefault && reassignTo == null) {
          throw const ValidationException(
            'Built-in categories cannot be deleted',
          );
        }

        final int inUse = await _isar.transactions
            .filter()
            .categoryIdEqualTo(id)
            .and()
            .isDeletedEqualTo(false)
            .count();

        if (inUse > 0 && reassignTo == null) {
          throw ValidationException(
            'This category is used by $inUse transaction'
            '${inUse == 1 ? '' : 's'}. Choose a category to move them to.',
          );
        }

        await _isar.isar.writeTxn(() async {
          if (reassignTo != null && inUse > 0) {
            final List<TransactionEntity> affected = await _isar.transactions
                .filter()
                .categoryIdEqualTo(id)
                .findAll();
            for (final TransactionEntity tx in affected) {
              await _isar.transactions.put(
                tx
                  ..categoryId = reassignTo
                  ..updatedAt = DateTime.now()
                  ..syncStatus = tx.syncStatus == SyncStatus.pendingCreate
                      ? SyncStatus.pendingCreate
                      : SyncStatus.pendingUpdate,
              );
            }
          }

          // Tombstone rather than remove, so the deletion can be replayed to
          // the server when connectivity returns.
          await _isar.categories.put(
            row
              ..isDeleted = true
              ..syncStatus = SyncStatus.pendingDelete
              ..updatedAt = DateTime.now(),
          );
        });
      });

  @override
  Future<Result<void>> seedDefaultsIfEmpty() => guard(() async {
    final int count = await _isar.categories.count();
    if (count > 0) return;

    final List<Category> defaults = DefaultCategories.build();
    await _isar.isar.writeTxn(() async {
      await _isar.categories.putAll(
        defaults.map((Category c) => c.toEntity()).toList(),
      );
    });
    AppLogger.i('Seeded ${defaults.length} default categories');
  });

  /// Duplicate names make the picker ambiguous, so they are rejected up front
  /// rather than discovered later.
  Future<void> _assertNameIsFree(Category category) async {
    final CategoryEntity? clash = await _isar.categories
        .filter()
        .nameEqualTo(category.name.trim(), caseSensitive: false)
        .and()
        .isDeletedEqualTo(false)
        .and()
        .not()
        .uidEqualTo(category.id)
        .findFirst();

    if (clash != null) {
      throw const ValidationException(
        'A category with that name already exists',
        fieldErrors: <String, List<String>>{
          'name': <String>['A category with that name already exists'],
        },
      );
    }
  }
}
