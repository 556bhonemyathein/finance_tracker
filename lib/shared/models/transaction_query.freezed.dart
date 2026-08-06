// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction_query.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TransactionQuery {

 String get search; Set<TransactionType> get types; Set<String> get categoryIds; DateTime? get from; DateTime? get to; double? get minAmount; double? get maxAmount; TransactionSort get sort; int get page; int get pageSize;
/// Create a copy of TransactionQuery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionQueryCopyWith<TransactionQuery> get copyWith => _$TransactionQueryCopyWithImpl<TransactionQuery>(this as TransactionQuery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionQuery&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other.types, types)&&const DeepCollectionEquality().equals(other.categoryIds, categoryIds)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(types),const DeepCollectionEquality().hash(categoryIds),from,to,minAmount,maxAmount,sort,page,pageSize);

@override
String toString() {
  return 'TransactionQuery(search: $search, types: $types, categoryIds: $categoryIds, from: $from, to: $to, minAmount: $minAmount, maxAmount: $maxAmount, sort: $sort, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class $TransactionQueryCopyWith<$Res>  {
  factory $TransactionQueryCopyWith(TransactionQuery value, $Res Function(TransactionQuery) _then) = _$TransactionQueryCopyWithImpl;
@useResult
$Res call({
 String search, Set<TransactionType> types, Set<String> categoryIds, DateTime? from, DateTime? to, double? minAmount, double? maxAmount, TransactionSort sort, int page, int pageSize
});




}
/// @nodoc
class _$TransactionQueryCopyWithImpl<$Res>
    implements $TransactionQueryCopyWith<$Res> {
  _$TransactionQueryCopyWithImpl(this._self, this._then);

  final TransactionQuery _self;
  final $Res Function(TransactionQuery) _then;

/// Create a copy of TransactionQuery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? search = null,Object? types = null,Object? categoryIds = null,Object? from = freezed,Object? to = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sort = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_self.copyWith(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self.types : types // ignore: cast_nullable_to_non_nullable
as Set<TransactionType>,categoryIds: null == categoryIds ? _self.categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TransactionSort,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionQuery].
extension TransactionQueryPatterns on TransactionQuery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionQuery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionQuery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionQuery value)  $default,){
final _that = this;
switch (_that) {
case _TransactionQuery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionQuery value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionQuery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String search,  Set<TransactionType> types,  Set<String> categoryIds,  DateTime? from,  DateTime? to,  double? minAmount,  double? maxAmount,  TransactionSort sort,  int page,  int pageSize)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionQuery() when $default != null:
return $default(_that.search,_that.types,_that.categoryIds,_that.from,_that.to,_that.minAmount,_that.maxAmount,_that.sort,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String search,  Set<TransactionType> types,  Set<String> categoryIds,  DateTime? from,  DateTime? to,  double? minAmount,  double? maxAmount,  TransactionSort sort,  int page,  int pageSize)  $default,) {final _that = this;
switch (_that) {
case _TransactionQuery():
return $default(_that.search,_that.types,_that.categoryIds,_that.from,_that.to,_that.minAmount,_that.maxAmount,_that.sort,_that.page,_that.pageSize);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String search,  Set<TransactionType> types,  Set<String> categoryIds,  DateTime? from,  DateTime? to,  double? minAmount,  double? maxAmount,  TransactionSort sort,  int page,  int pageSize)?  $default,) {final _that = this;
switch (_that) {
case _TransactionQuery() when $default != null:
return $default(_that.search,_that.types,_that.categoryIds,_that.from,_that.to,_that.minAmount,_that.maxAmount,_that.sort,_that.page,_that.pageSize);case _:
  return null;

}
}

}

/// @nodoc


class _TransactionQuery extends TransactionQuery {
  const _TransactionQuery({this.search = '', final  Set<TransactionType> types = const <TransactionType>{}, final  Set<String> categoryIds = const <String>{}, this.from, this.to, this.minAmount, this.maxAmount, this.sort = TransactionSort.dateDesc, this.page = 0, this.pageSize = 20}): _types = types,_categoryIds = categoryIds,super._();
  

@override@JsonKey() final  String search;
 final  Set<TransactionType> _types;
@override@JsonKey() Set<TransactionType> get types {
  if (_types is EqualUnmodifiableSetView) return _types;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_types);
}

 final  Set<String> _categoryIds;
@override@JsonKey() Set<String> get categoryIds {
  if (_categoryIds is EqualUnmodifiableSetView) return _categoryIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_categoryIds);
}

@override final  DateTime? from;
@override final  DateTime? to;
@override final  double? minAmount;
@override final  double? maxAmount;
@override@JsonKey() final  TransactionSort sort;
@override@JsonKey() final  int page;
@override@JsonKey() final  int pageSize;

/// Create a copy of TransactionQuery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionQueryCopyWith<_TransactionQuery> get copyWith => __$TransactionQueryCopyWithImpl<_TransactionQuery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionQuery&&(identical(other.search, search) || other.search == search)&&const DeepCollectionEquality().equals(other._types, _types)&&const DeepCollectionEquality().equals(other._categoryIds, _categoryIds)&&(identical(other.from, from) || other.from == from)&&(identical(other.to, to) || other.to == to)&&(identical(other.minAmount, minAmount) || other.minAmount == minAmount)&&(identical(other.maxAmount, maxAmount) || other.maxAmount == maxAmount)&&(identical(other.sort, sort) || other.sort == sort)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize));
}


@override
int get hashCode => Object.hash(runtimeType,search,const DeepCollectionEquality().hash(_types),const DeepCollectionEquality().hash(_categoryIds),from,to,minAmount,maxAmount,sort,page,pageSize);

@override
String toString() {
  return 'TransactionQuery(search: $search, types: $types, categoryIds: $categoryIds, from: $from, to: $to, minAmount: $minAmount, maxAmount: $maxAmount, sort: $sort, page: $page, pageSize: $pageSize)';
}


}

/// @nodoc
abstract mixin class _$TransactionQueryCopyWith<$Res> implements $TransactionQueryCopyWith<$Res> {
  factory _$TransactionQueryCopyWith(_TransactionQuery value, $Res Function(_TransactionQuery) _then) = __$TransactionQueryCopyWithImpl;
@override @useResult
$Res call({
 String search, Set<TransactionType> types, Set<String> categoryIds, DateTime? from, DateTime? to, double? minAmount, double? maxAmount, TransactionSort sort, int page, int pageSize
});




}
/// @nodoc
class __$TransactionQueryCopyWithImpl<$Res>
    implements _$TransactionQueryCopyWith<$Res> {
  __$TransactionQueryCopyWithImpl(this._self, this._then);

  final _TransactionQuery _self;
  final $Res Function(_TransactionQuery) _then;

/// Create a copy of TransactionQuery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? search = null,Object? types = null,Object? categoryIds = null,Object? from = freezed,Object? to = freezed,Object? minAmount = freezed,Object? maxAmount = freezed,Object? sort = null,Object? page = null,Object? pageSize = null,}) {
  return _then(_TransactionQuery(
search: null == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String,types: null == types ? _self._types : types // ignore: cast_nullable_to_non_nullable
as Set<TransactionType>,categoryIds: null == categoryIds ? _self._categoryIds : categoryIds // ignore: cast_nullable_to_non_nullable
as Set<String>,from: freezed == from ? _self.from : from // ignore: cast_nullable_to_non_nullable
as DateTime?,to: freezed == to ? _self.to : to // ignore: cast_nullable_to_non_nullable
as DateTime?,minAmount: freezed == minAmount ? _self.minAmount : minAmount // ignore: cast_nullable_to_non_nullable
as double?,maxAmount: freezed == maxAmount ? _self.maxAmount : maxAmount // ignore: cast_nullable_to_non_nullable
as double?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as TransactionSort,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
