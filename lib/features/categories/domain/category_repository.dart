import '../../../core/utils/result.dart';
import '../../../shared/models/category.dart';

/// Category persistence contract.
abstract interface class CategoryRepository {
  /// Live list of non-deleted categories, ordered by [Category.sortOrder].
  ///
  /// A [Stream] rather than a `Future` because Isar can push updates: add a
  /// category on the manage screen and the transaction form's dropdown updates
  /// itself with no manual invalidation anywhere.
  Stream<List<Category>> watchAll();

  Future<Result<List<Category>>> getAll();

  Future<Result<Category>> create(Category category);

  Future<Result<Category>> update(Category category);

  /// Soft-deletes. Fails if the category still has transactions, unless
  /// [reassignTo] names a replacement.
  Future<Result<void>> delete(String id, {String? reassignTo});

  /// Seeds the starter set the first time the app runs.
  Future<Result<void>> seedDefaultsIfEmpty();
}
