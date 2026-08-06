import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/models/category.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/providers/core_providers.dart';
import '../../data/category_repository_impl.dart';
import '../../domain/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (Ref ref) => CategoryRepositoryImpl(ref.watch(isarServiceProvider)),
  name: 'categoryRepository',
);

/// Live categories.
///
/// A [StreamProvider] over Isar's change feed: create a category on the manage
/// screen and every dropdown, chart legend and filter sheet in the app updates
/// itself. No `ref.invalidate` calls, no stale lists.
final categoriesProvider = StreamProvider<List<Category>>(
  (Ref ref) => ref.watch(categoryRepositoryProvider).watchAll(),
  name: 'categories',
);

/// Categories valid for a given transaction type — the form's dropdown source.
///
/// A `family` keyed by [TransactionType]: Riverpod caches one filtered list per
/// type and rebuilds only the dropdown that cares when the source list changes.
final categoriesByTypeProvider =
    Provider.family<List<Category>, TransactionType>((
      Ref ref,
      TransactionType type,
    ) {
      final List<Category> all =
          ref.watch(categoriesProvider).value ?? const <Category>[];
      return all
          .where((Category c) => c.kind.allows(type))
          .toList(growable: false);
    }, name: 'categoriesByType');

/// O(1) lookup used by every transaction tile.
///
/// Without this, rendering a 200-row list would run 200 linear scans. Falls
/// back to [Category.unknown] so a dangling reference renders gracefully
/// instead of throwing mid-build.
final categoryLookupProvider = Provider<Map<String, Category>>((Ref ref) {
  final List<Category> all =
      ref.watch(categoriesProvider).value ?? const <Category>[];
  return <String, Category>{for (final Category c in all) c.id: c};
}, name: 'categoryLookup');

final categoryByIdProvider = Provider.family<Category, String>(
  (Ref ref, String id) =>
      ref.watch(categoryLookupProvider)[id] ?? Category.unknown,
  name: 'categoryById',
);

/// Write-side commands for categories.
///
/// Reads flow through [categoriesProvider]; writes go through this notifier.
/// Separating them means the list never sits in a loading state just because a
/// rename is in flight. State is the in-flight status of the last command.
class CategoryController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  CategoryRepository get _repository => ref.read(categoryRepositoryProvider);

  Future<Failure?> create(Category category) =>
      _execute(() => _repository.create(category));

  /// Named `edit` rather than `update` because `AsyncNotifier` already
  /// declares an `update` member with a different signature.
  Future<Failure?> edit(Category category) =>
      _execute(() => _repository.update(category));

  Future<Failure?> delete(String id, {String? reassignTo}) =>
      _execute(() => _repository.delete(id, reassignTo: reassignTo));

  Future<Failure?> _execute(Future<Result<Object?>> Function() action) async {
    state = const AsyncLoading<void>();
    final Result<Object?> result = await action();
    state = const AsyncData<void>(null);
    return result.failureOrNull;
  }
}

final categoryControllerProvider =
    AsyncNotifierProvider<CategoryController, void>(
      CategoryController.new,
      name: 'categoryController',
    );
