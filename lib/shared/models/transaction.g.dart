// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Transaction _$TransactionFromJson(Map<String, dynamic> json) => _Transaction(
  id: json['id'] as String,
  type: $enumDecode(_$TransactionTypeEnumMap, json['type']),
  amount: (json['amount'] as num).toDouble(),
  date: DateTime.parse(json['date'] as String),
  categoryId: json['categoryId'] as String,
  currencyCode: json['currencyCode'] as String? ?? 'USD',
  note: json['note'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  receiptPath: json['receiptPath'] as String?,
  attachments:
      (json['attachments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  recurrence:
      $enumDecodeNullable(_$RecurrenceRuleEnumMap, json['recurrence']) ??
      RecurrenceRule.none,
  transferTo: json['transferTo'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  syncStatus:
      $enumDecodeNullable(_$SyncStatusEnumMap, json['syncStatus']) ??
      SyncStatus.pendingCreate,
);

Map<String, dynamic> _$TransactionToJson(_Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$TransactionTypeEnumMap[instance.type]!,
      'amount': instance.amount,
      'date': instance.date.toIso8601String(),
      'categoryId': instance.categoryId,
      'currencyCode': instance.currencyCode,
      'note': instance.note,
      'tags': instance.tags,
      'receiptPath': instance.receiptPath,
      'attachments': instance.attachments,
      'recurrence': _$RecurrenceRuleEnumMap[instance.recurrence]!,
      'transferTo': instance.transferTo,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'syncStatus': _$SyncStatusEnumMap[instance.syncStatus]!,
    };

const _$TransactionTypeEnumMap = {
  TransactionType.income: 'income',
  TransactionType.expense: 'expense',
  TransactionType.transfer: 'transfer',
};

const _$RecurrenceRuleEnumMap = {
  RecurrenceRule.none: 'none',
  RecurrenceRule.daily: 'daily',
  RecurrenceRule.weekly: 'weekly',
  RecurrenceRule.monthly: 'monthly',
  RecurrenceRule.yearly: 'yearly',
};

const _$SyncStatusEnumMap = {
  SyncStatus.synced: 'synced',
  SyncStatus.pendingCreate: 'pendingCreate',
  SyncStatus.pendingUpdate: 'pendingUpdate',
  SyncStatus.pendingDelete: 'pendingDelete',
};
