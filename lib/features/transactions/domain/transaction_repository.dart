import '../../../core/utils/result.dart';
import '../../../shared/models/transaction.dart';
import '../../../shared/models/transaction_query.dart';

/// A page of results plus the cursor state the list needs to keep scrolling.
class TransactionPage {
  const TransactionPage({
    required this.items,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  final List<Transaction> items;

  /// Total matching the filters, ignoring paging — drives the "N results"
  /// label without a second query.
  final int total;

  final int page;
  final bool hasMore;

  static const TransactionPage empty = TransactionPage(
    items: <Transaction>[],
    total: 0,
    page: 0,
    hasMore: false,
  );
}

/// Aggregates for the dashboard and reports.
///
/// Computed by the repository rather than in the UI so the maths lives next to
/// the data and is unit-testable without pumping a widget.
class TransactionSummary {
  const TransactionSummary({
    required this.income,
    required this.expense,
    required this.transfers,
    required this.count,
  });

  final double income;
  final double expense;
  final double transfers;
  final int count;

  double get balance => income - expense;

  /// Share of income kept. Zero income means an undefined rate, reported as 0
  /// rather than NaN so the UI never has to guard against it.
  double get savingsRate => income <= 0 ? 0 : (income - expense) / income;

  static const TransactionSummary zero = TransactionSummary(
    income: 0,
    expense: 0,
    transfers: 0,
    count: 0,
  );
}

abstract interface class TransactionRepository {
  /// Live, filtered, paginated list.
  Stream<TransactionPage> watchPage(TransactionQuery query);

  Future<Result<TransactionPage>> getPage(TransactionQuery query);

  Future<Result<Transaction?>> getById(String id);

  /// Live totals for a date range — the dashboard cards subscribe to this.
  Stream<TransactionSummary> watchSummary({
    required DateTime from,
    required DateTime to,
  });

  /// Totals grouped by category, biggest first. Backs the reports pie chart.
  Future<Result<Map<String, double>>> totalsByCategory({
    required DateTime from,
    required DateTime to,
    required bool expensesOnly,
  });

  /// Totals per day in the range, zero-filled — the bar/line charts need a
  /// point for every day, including the ones with no activity.
  Future<Result<List<({DateTime day, double income, double expense})>>>
  dailyTotals({required DateTime from, required DateTime to});

  Future<Result<Transaction>> create(Transaction transaction);

  Future<Result<Transaction>> update(Transaction transaction);

  Future<Result<void>> delete(String id);

  /// Undo support: restores a tombstoned row.
  Future<Result<void>> restore(String id);

  /// Materialises the next occurrence of each due recurring transaction.
  Future<Result<int>> materialiseRecurring();

  /// Everything still awaiting a push to the server.
  Future<Result<List<Transaction>>> pendingSync();

  Future<Result<void>> markSynced(Iterable<String> ids);

  /// Full export used by Backup and by CSV/PDF report generation.
  Future<Result<List<Transaction>>> exportAll();

  Future<Result<int>> importAll(List<Transaction> transactions);
}
