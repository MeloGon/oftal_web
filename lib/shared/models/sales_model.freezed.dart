// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesModel {

 int get id; String? get branch; String? get date; String? get patient; String? get authorName; double? get total; double? get discount; double? get totalWithDiscount; double? get account; double? get rest; String? get folioSale;
/// Create a copy of SalesModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesModelCopyWith<SalesModel> get copyWith => _$SalesModelCopyWithImpl<SalesModel>(this as SalesModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesModel&&(identical(other.id, id) || other.id == id)&&(identical(other.branch, branch) || other.branch == branch)&&(identical(other.date, date) || other.date == date)&&(identical(other.patient, patient) || other.patient == patient)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.total, total) || other.total == total)&&(identical(other.discount, discount) || other.discount == discount)&&(identical(other.totalWithDiscount, totalWithDiscount) || other.totalWithDiscount == totalWithDiscount)&&(identical(other.account, account) || other.account == account)&&(identical(other.rest, rest) || other.rest == rest)&&(identical(other.folioSale, folioSale) || other.folioSale == folioSale));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,branch,date,patient,authorName,total,discount,totalWithDiscount,account,rest,folioSale);

@override
String toString() {
  return 'SalesModel(id: $id, branch: $branch, date: $date, patient: $patient, authorName: $authorName, total: $total, discount: $discount, totalWithDiscount: $totalWithDiscount, account: $account, rest: $rest, folioSale: $folioSale)';
}


}

/// @nodoc
abstract mixin class $SalesModelCopyWith<$Res>  {
  factory $SalesModelCopyWith(SalesModel value, $Res Function(SalesModel) _then) = _$SalesModelCopyWithImpl;
@useResult
$Res call({
 int id, String? branch, String? date, String? patient, String? authorName, double? total, double? discount, double? totalWithDiscount, double? account, double? rest, String? folioSale
});




}
/// @nodoc
class _$SalesModelCopyWithImpl<$Res>
    implements $SalesModelCopyWith<$Res> {
  _$SalesModelCopyWithImpl(this._self, this._then);

  final SalesModel _self;
  final $Res Function(SalesModel) _then;

/// Create a copy of SalesModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? branch = freezed,Object? date = freezed,Object? patient = freezed,Object? authorName = freezed,Object? total = freezed,Object? discount = freezed,Object? totalWithDiscount = freezed,Object? account = freezed,Object? rest = freezed,Object? folioSale = freezed,}) {
  return _then(SalesModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,branch: freezed == branch ? _self.branch : branch // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,patient: freezed == patient ? _self.patient : patient // ignore: cast_nullable_to_non_nullable
as String?,authorName: freezed == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String?,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as double?,discount: freezed == discount ? _self.discount : discount // ignore: cast_nullable_to_non_nullable
as double?,totalWithDiscount: freezed == totalWithDiscount ? _self.totalWithDiscount : totalWithDiscount // ignore: cast_nullable_to_non_nullable
as double?,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as double?,rest: freezed == rest ? _self.rest : rest // ignore: cast_nullable_to_non_nullable
as double?,folioSale: freezed == folioSale ? _self.folioSale : folioSale // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesModel].
extension SalesModelPatterns on SalesModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({required TResult orElse(),}){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(){
final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({required TResult orElse(),}) {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>() {final _that = this;
switch (_that) {
case _:
  return null;

}
}

}

// dart format on
