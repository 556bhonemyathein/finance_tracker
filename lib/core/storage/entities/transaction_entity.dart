import 'package:isar_community/isar.dart';

import '../../../shared/models/enums.dart';
import '../../../shared/models/transaction.dart';

part 'transaction_entity.g.dart';

/// Isar row for a transaction.
///
/// Kept separate from the [Transaction] domain model on purpose: persistence
/// concerns (auto-increment `Id`, index declarations, enum storage format) are
/// the database's business, not the domain's. The two are bridged by
/// [toDomain] / [TransactionEntityX.toEntity] and nowhere else.
@collection
class TransactionEntity {
  Id isarId = Isar.autoIncrement;

  /// Client-generated UUID. Unique + indexed because every lookup, upsert and
  /// sync reconciliation happens by this id rather than by the Isar row id.
  @Index(unique: true, replace: true)
  late String uid;

  @Enumerated(EnumType.name)
  late TransactionType type;

  late double amount;

  /// Indexed: the list, the dashboard and every report sort or range-scan on
  /// date, which would otherwise be a full collection walk.
  @Index()
  late DateTime date;

  @Index()
  late String categoryId;

  late String currencyCode;

  late String note;

  List<String> tags = <String>[];

  String? receiptPath;

  List<String> attachments = <String>[];

  @Enumerated(EnumType.name)
  late RecurrenceRule recurrence;

  String? transferTo;

  late DateTime createdAt;

  late DateTime updatedAt;

  /// Indexed so the sync engine can pull "everything still pending" cheaply.
  @Index()
  @Enumerated(EnumType.name)
  late SyncStatus syncStatus;

  /// Soft delete. Rows are tombstoned rather than removed so the server can be
  /// told about the deletion when connectivity returns.
  @Index()
  bool isDeleted = false;

  Transaction toDomain() => Transaction(
    id: uid,
    type: type,
    amount: amount,
    date: date,
    categoryId: categoryId,
    currencyCode: currencyCode,
    note: note,
    tags: tags,
    receiptPath: receiptPath,
    attachments: attachments,
    recurrence: recurrence,
    transferTo: transferTo,
    createdAt: createdAt,
    updatedAt: updatedAt,
    syncStatus: syncStatus,
  );
}

extension TransactionEntityX on Transaction {
  TransactionEntity toEntity({int? isarId}) {
    final DateTime now = DateTime.now();
    return TransactionEntity()
      ..isarId = isarId ?? Isar.autoIncrement
      ..uid = id
      ..type = type
      ..amount = amount
      ..date = date
      ..categoryId = categoryId
      ..currencyCode = currencyCode
      ..note = note
      ..tags = tags
      ..receiptPath = receiptPath
      ..attachments = attachments
      ..recurrence = recurrence
      ..transferTo = transferTo
      ..createdAt = createdAt ?? now
      ..updatedAt = updatedAt ?? now
      ..syncStatus = syncStatus
      ..isDeleted = syncStatus == SyncStatus.pendingDelete;
  }
}
