import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'transaction_query.freezed.dart';

/// Every knob the transaction list exposes, in one immutable value object.
///
/// Bundling search + filters + sort + paging into a single object is what makes
/// the list provider a clean `family`: `ref.watch(transactionsProvider(query))`.
/// Because it is a Freezed class it has value equality, so Riverpod caches by
/// *content* — two screens asking for the same filters share one subscription.
@freezed
abstract class TransactionQuery with _$TransactionQuery {
  const factory TransactionQuery({
    @Default('') String search,
    @Default(<TransactionType>{}) Set<TransactionType> types,
    @Default(<String>{}) Set<String> categoryIds,
    DateTime? from,
    DateTime? to,
    double? minAmount,
    double? maxAmount,
    @Default(TransactionSort.dateDesc) TransactionSort sort,
    @Default(0) int page,
    @Default(20) int pageSize,
  }) = _TransactionQuery;

  const TransactionQuery._();

  /// True when the user has narrowed the list in any way — drives the "clear
  /// filters" affordance and the filter-count badge.
  bool get hasFilters =>
      types.isNotEmpty ||
      categoryIds.isNotEmpty ||
      from != null ||
      to != null ||
      minAmount != null ||
      maxAmount != null;

  int get activeFilterCount => <bool>[
    types.isNotEmpty,
    categoryIds.isNotEmpty,
    from != null || to != null,
    minAmount != null || maxAmount != null,
  ].where((bool active) => active).length;

  /// Same filters, first page — used whenever a filter changes.
  TransactionQuery get resetPage => copyWith(page: 0);

  /// Drops paging so a query can be used as a cache key for aggregate maths.
  TransactionQuery get withoutPaging =>
      copyWith(page: 0, pageSize: 1 << 30);
}
