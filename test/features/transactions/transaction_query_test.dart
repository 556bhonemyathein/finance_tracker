import 'package:finance_tracker/core/storage/preferences_service.dart';
import 'package:finance_tracker/features/transactions/presentation/providers/transaction_providers.dart';
import 'package:finance_tracker/shared/models/enums.dart';
import 'package:finance_tracker/shared/models/transaction_query.dart';
import 'package:finance_tracker/shared/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tests for the query notifier — the state machine behind search, filters,
/// sorting and pagination.
///
/// This is where the transaction list's correctness actually lives, and it is
/// testable without a database, a widget or a network because the notifier
/// only manipulates an immutable value object.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final PreferencesService preferences = await PreferencesService.create();

    container = ProviderContainer(
      overrides: [preferencesServiceProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);
  });

  TransactionQueryNotifier notifier() =>
      container.read(transactionQueryProvider.notifier);

  TransactionQuery query() => container.read(transactionQueryProvider);

  group('filters', () {
    test('starts empty', () {
      expect(query().hasFilters, isFalse);
      expect(query().activeFilterCount, 0);
      expect(query().page, 0);
    });

    test('toggling a type adds then removes it', () {
      notifier().toggleType(TransactionType.expense);
      expect(query().types, <TransactionType>{TransactionType.expense});

      notifier().toggleType(TransactionType.expense);
      expect(query().types, isEmpty);
    });

    test('toggling a category adds then removes it', () {
      notifier().toggleCategory('groceries');
      expect(query().categoryIds, <String>{'groceries'});

      notifier().toggleCategory('groceries');
      expect(query().categoryIds, isEmpty);
    });

    test('counts each active filter group once', () {
      notifier()
        ..toggleType(TransactionType.income)
        ..toggleType(TransactionType.expense)
        ..toggleCategory('rent')
        ..setDateRange(DateTime(2026), DateTime(2026, 12, 31))
        ..setAmountRange(10, 500);

      // types + categories + dates + amounts == 4, despite six calls.
      expect(query().activeFilterCount, 4);
      expect(query().hasFilters, isTrue);
    });

    test('clearFilters keeps the search term and sort order', () {
      notifier()
        ..searchNow('coffee')
        ..setSort(TransactionSort.amountDesc)
        ..toggleType(TransactionType.expense)
        ..clearFilters();

      expect(query().search, 'coffee');
      expect(query().sort, TransactionSort.amountDesc);
      expect(query().hasFilters, isFalse);
    });

    test('reset clears everything', () {
      notifier()
        ..searchNow('coffee')
        ..toggleType(TransactionType.expense)
        ..reset();

      expect(query(), const TransactionQuery());
    });
  });

  group('pagination', () {
    test('loadMore advances the page', () {
      notifier()
        ..loadMore()
        ..loadMore();
      expect(query().page, 2);
    });

    test('changing a filter returns to the first page', () {
      notifier()
        ..loadMore()
        ..loadMore();
      expect(query().page, 2);

      notifier().toggleType(TransactionType.income);
      expect(query().page, 0);
    });

    test('changing the sort returns to the first page', () {
      notifier().loadMore();
      notifier().setSort(TransactionSort.amountAsc);
      expect(query().page, 0);
    });
  });

  group('search', () {
    test('searchNow applies immediately', () {
      notifier().searchNow('rent');
      expect(query().search, 'rent');
    });

    test('search is debounced', () async {
      notifier().search('gro');
      // Nothing has been committed yet — the debounce is still pending.
      expect(query().search, '');

      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(query().search, 'gro');
    });

    test('rapid typing produces only the final term', () async {
      notifier()
        ..search('g')
        ..search('gr')
        ..search('gro');

      await Future<void>.delayed(const Duration(milliseconds: 450));
      expect(query().search, 'gro');
    });
  });

  group('TransactionQuery value semantics', () {
    test('equal filters compare equal, so Riverpod caches by content', () {
      const TransactionQuery a = TransactionQuery(
        search: 'x',
        types: <TransactionType>{TransactionType.expense},
      );
      const TransactionQuery b = TransactionQuery(
        search: 'x',
        types: <TransactionType>{TransactionType.expense},
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('withoutPaging widens the page size and resets the index', () {
      const TransactionQuery paged = TransactionQuery(page: 3, pageSize: 20);
      expect(paged.withoutPaging.page, 0);
      expect(paged.withoutPaging.pageSize, greaterThan(1000));
    });
  });
}
