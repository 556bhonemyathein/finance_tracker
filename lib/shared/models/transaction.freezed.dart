// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Transaction {

/// Client-generated UUID — stable across offline creation and later sync,
/// which is what lets the app create rows without waiting for a server id.
 String get id; TransactionType get type; double get amount; DateTime get date; String get categoryId; String get currencyCode; String get note; List<String> get tags; String? get receiptPath; List<String> get attachments; RecurrenceRule get recurrence;/// For transfers: the destination pot/account label.
 String? get transferTo; DateTime? get createdAt; DateTime? get updatedAt; SyncStatus get syncStatus;
/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionCopyWith<Transaction> get copyWith => _$TransactionCopyWithImpl<Transaction>(this as Transaction, _$identity);

  /// Serializes this Transaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath)&&const DeepCollectionEquality().equals(other.attachments, attachments)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.transferTo, transferTo) || other.transferTo == transferTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,date,categoryId,currencyCode,note,const DeepCollectionEquality().hash(tags),receiptPath,const DeepCollectionEquality().hash(attachments),recurrence,transferTo,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Transaction(id: $id, type: $type, amount: $amount, date: $date, categoryId: $categoryId, currencyCode: $currencyCode, note: $note, tags: $tags, receiptPath: $receiptPath, attachments: $attachments, recurrence: $recurrence, transferTo: $transferTo, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class $TransactionCopyWith<$Res>  {
  factory $TransactionCopyWith(Transaction value, $Res Function(Transaction) _then) = _$TransactionCopyWithImpl;
@useResult
$Res call({
 String id, TransactionType type, double amount, DateTime date, String categoryId, String currencyCode, String note, List<String> tags, String? receiptPath, List<String> attachments, RecurrenceRule recurrence, String? transferTo, DateTime? createdAt, DateTime? updatedAt, SyncStatus syncStatus
});




}
/// @nodoc
class _$TransactionCopyWithImpl<$Res>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._self, this._then);

  final Transaction _self;
  final $Res Function(Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? date = null,Object? categoryId = null,Object? currencyCode = null,Object? note = null,Object? tags = null,Object? receiptPath = freezed,Object? attachments = null,Object? recurrence = null,Object? transferTo = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? syncStatus = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,transferTo: freezed == transferTo ? _self.transferTo : transferTo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [Transaction].
extension TransactionPatterns on Transaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Transaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Transaction value)  $default,){
final _that = this;
switch (_that) {
case _Transaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Transaction value)?  $default,){
final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  TransactionType type,  double amount,  DateTime date,  String categoryId,  String currencyCode,  String note,  List<String> tags,  String? receiptPath,  List<String> attachments,  RecurrenceRule recurrence,  String? transferTo,  DateTime? createdAt,  DateTime? updatedAt,  SyncStatus syncStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.date,_that.categoryId,_that.currencyCode,_that.note,_that.tags,_that.receiptPath,_that.attachments,_that.recurrence,_that.transferTo,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  TransactionType type,  double amount,  DateTime date,  String categoryId,  String currencyCode,  String note,  List<String> tags,  String? receiptPath,  List<String> attachments,  RecurrenceRule recurrence,  String? transferTo,  DateTime? createdAt,  DateTime? updatedAt,  SyncStatus syncStatus)  $default,) {final _that = this;
switch (_that) {
case _Transaction():
return $default(_that.id,_that.type,_that.amount,_that.date,_that.categoryId,_that.currencyCode,_that.note,_that.tags,_that.receiptPath,_that.attachments,_that.recurrence,_that.transferTo,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  TransactionType type,  double amount,  DateTime date,  String categoryId,  String currencyCode,  String note,  List<String> tags,  String? receiptPath,  List<String> attachments,  RecurrenceRule recurrence,  String? transferTo,  DateTime? createdAt,  DateTime? updatedAt,  SyncStatus syncStatus)?  $default,) {final _that = this;
switch (_that) {
case _Transaction() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.date,_that.categoryId,_that.currencyCode,_that.note,_that.tags,_that.receiptPath,_that.attachments,_that.recurrence,_that.transferTo,_that.createdAt,_that.updatedAt,_that.syncStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Transaction extends Transaction {
  const _Transaction({required this.id, required this.type, required this.amount, required this.date, required this.categoryId, this.currencyCode = 'USD', this.note = '', final  List<String> tags = const <String>[], this.receiptPath, final  List<String> attachments = const <String>[], this.recurrence = RecurrenceRule.none, this.transferTo, this.createdAt, this.updatedAt, this.syncStatus = SyncStatus.pendingCreate}): _tags = tags,_attachments = attachments,super._();
  factory _Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);

/// Client-generated UUID — stable across offline creation and later sync,
/// which is what lets the app create rows without waiting for a server id.
@override final  String id;
@override final  TransactionType type;
@override final  double amount;
@override final  DateTime date;
@override final  String categoryId;
@override@JsonKey() final  String currencyCode;
@override@JsonKey() final  String note;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override final  String? receiptPath;
 final  List<String> _attachments;
@override@JsonKey() List<String> get attachments {
  if (_attachments is EqualUnmodifiableListView) return _attachments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attachments);
}

@override@JsonKey() final  RecurrenceRule recurrence;
/// For transfers: the destination pot/account label.
@override final  String? transferTo;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  SyncStatus syncStatus;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionCopyWith<_Transaction> get copyWith => __$TransactionCopyWithImpl<_Transaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Transaction&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.date, date) || other.date == date)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.note, note) || other.note == note)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.receiptPath, receiptPath) || other.receiptPath == receiptPath)&&const DeepCollectionEquality().equals(other._attachments, _attachments)&&(identical(other.recurrence, recurrence) || other.recurrence == recurrence)&&(identical(other.transferTo, transferTo) || other.transferTo == transferTo)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.syncStatus, syncStatus) || other.syncStatus == syncStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,amount,date,categoryId,currencyCode,note,const DeepCollectionEquality().hash(_tags),receiptPath,const DeepCollectionEquality().hash(_attachments),recurrence,transferTo,createdAt,updatedAt,syncStatus);

@override
String toString() {
  return 'Transaction(id: $id, type: $type, amount: $amount, date: $date, categoryId: $categoryId, currencyCode: $currencyCode, note: $note, tags: $tags, receiptPath: $receiptPath, attachments: $attachments, recurrence: $recurrence, transferTo: $transferTo, createdAt: $createdAt, updatedAt: $updatedAt, syncStatus: $syncStatus)';
}


}

/// @nodoc
abstract mixin class _$TransactionCopyWith<$Res> implements $TransactionCopyWith<$Res> {
  factory _$TransactionCopyWith(_Transaction value, $Res Function(_Transaction) _then) = __$TransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, TransactionType type, double amount, DateTime date, String categoryId, String currencyCode, String note, List<String> tags, String? receiptPath, List<String> attachments, RecurrenceRule recurrence, String? transferTo, DateTime? createdAt, DateTime? updatedAt, SyncStatus syncStatus
});




}
/// @nodoc
class __$TransactionCopyWithImpl<$Res>
    implements _$TransactionCopyWith<$Res> {
  __$TransactionCopyWithImpl(this._self, this._then);

  final _Transaction _self;
  final $Res Function(_Transaction) _then;

/// Create a copy of Transaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? date = null,Object? categoryId = null,Object? currencyCode = null,Object? note = null,Object? tags = null,Object? receiptPath = freezed,Object? attachments = null,Object? recurrence = null,Object? transferTo = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? syncStatus = null,}) {
  return _then(_Transaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as TransactionType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,note: null == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,receiptPath: freezed == receiptPath ? _self.receiptPath : receiptPath // ignore: cast_nullable_to_non_nullable
as String?,attachments: null == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<String>,recurrence: null == recurrence ? _self.recurrence : recurrence // ignore: cast_nullable_to_non_nullable
as RecurrenceRule,transferTo: freezed == transferTo ? _self.transferTo : transferTo // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,syncStatus: null == syncStatus ? _self.syncStatus : syncStatus // ignore: cast_nullable_to_non_nullable
as SyncStatus,
  ));
}


}

// dart format on
