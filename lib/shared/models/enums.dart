/// Cross-feature enums.
///
/// They live in `shared/models` because both the transactions feature and the
/// reports feature need them; putting them inside either feature would create
/// a horizontal dependency between siblings.
library;

/// What a money movement does to the balance.
enum TransactionType {
  income('Income'),
  expense('Expense'),
  transfer('Transfer');

  const TransactionType(this.label);

  final String label;

  /// Signed multiplier applied when summing into the balance.
  /// A transfer moves money between the user's own pots, so it is balance
  /// neutral — this is why balance maths never special-cases it.
  int get sign => switch (this) {
    TransactionType.income => 1,
    TransactionType.expense => -1,
    TransactionType.transfer => 0,
  };

  static TransactionType fromName(String? value) =>
      TransactionType.values.firstWhere(
        (TransactionType t) => t.name == value,
        orElse: () => TransactionType.expense,
      );
}

/// Which transaction types a category may be attached to.
enum CategoryKind {
  income,
  expense,
  both;

  bool allows(TransactionType type) => switch (this) {
    CategoryKind.both => true,
    CategoryKind.income => type == TransactionType.income,
    CategoryKind.expense => type != TransactionType.income,
  };

  static CategoryKind fromName(String? value) =>
      CategoryKind.values.firstWhere(
        (CategoryKind k) => k.name == value,
        orElse: () => CategoryKind.both,
      );
}

/// Offline-first bookkeeping: every locally written row records what the
/// server still owes an update for.
enum SyncStatus {
  /// Local copy matches the server.
  synced,

  /// Created offline, server has never seen it.
  pendingCreate,

  /// Exists on the server but was edited offline.
  pendingUpdate,

  /// Tombstoned locally, server still has it.
  pendingDelete;

  bool get isPending => this != SyncStatus.synced;
}

/// How often a recurring transaction repeats.
enum RecurrenceRule {
  none('Does not repeat'),
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const RecurrenceRule(this.label);

  final String label;

  /// Next occurrence after [from], or `null` when the rule does not repeat.
  DateTime? next(DateTime from) => switch (this) {
    RecurrenceRule.none => null,
    RecurrenceRule.daily => from.add(const Duration(days: 1)),
    RecurrenceRule.weekly => from.add(const Duration(days: 7)),
    RecurrenceRule.monthly => DateTime(from.year, from.month + 1, from.day),
    RecurrenceRule.yearly => DateTime(from.year + 1, from.month, from.day),
  };

  static RecurrenceRule fromName(String? value) =>
      RecurrenceRule.values.firstWhere(
        (RecurrenceRule r) => r.name == value,
        orElse: () => RecurrenceRule.none,
      );
}

/// Reporting window presets.
enum ReportPeriod {
  weekly('This week'),
  monthly('This month'),
  yearly('This year'),
  custom('Custom range');

  const ReportPeriod(this.label);

  final String label;
}

/// Sort options offered by the transaction list.
enum TransactionSort {
  dateDesc('Newest first'),
  dateAsc('Oldest first'),
  amountDesc('Highest amount'),
  amountAsc('Lowest amount');

  const TransactionSort(this.label);

  final String label;
}
