// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_symbol_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlotSymbolModel _$SlotSymbolModelFromJson(Map<String, dynamic> json) {
  return _SlotSymbolModel.fromJson(json);
}

/// @nodoc
mixin _$SlotSymbolModel {
  String get id => throw _privateConstructorUsedError;
  String get iconAsset => throw _privateConstructorUsedError;
  int get weight =>
      throw _privateConstructorUsedError; // key: number of matching symbols (e.g. "2" or "3")
// value: multiplier
  Map<String, double> get payoutTable => throw _privateConstructorUsedError;

  /// Serializes this SlotSymbolModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlotSymbolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotSymbolModelCopyWith<SlotSymbolModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotSymbolModelCopyWith<$Res> {
  factory $SlotSymbolModelCopyWith(
          SlotSymbolModel value, $Res Function(SlotSymbolModel) then) =
      _$SlotSymbolModelCopyWithImpl<$Res, SlotSymbolModel>;
  @useResult
  $Res call(
      {String id,
      String iconAsset,
      int weight,
      Map<String, double> payoutTable});
}

/// @nodoc
class _$SlotSymbolModelCopyWithImpl<$Res, $Val extends SlotSymbolModel>
    implements $SlotSymbolModelCopyWith<$Res> {
  _$SlotSymbolModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotSymbolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iconAsset = null,
    Object? weight = null,
    Object? payoutTable = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      iconAsset: null == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      payoutTable: null == payoutTable
          ? _value.payoutTable
          : payoutTable // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SlotSymbolModelImplCopyWith<$Res>
    implements $SlotSymbolModelCopyWith<$Res> {
  factory _$$SlotSymbolModelImplCopyWith(_$SlotSymbolModelImpl value,
          $Res Function(_$SlotSymbolModelImpl) then) =
      __$$SlotSymbolModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String iconAsset,
      int weight,
      Map<String, double> payoutTable});
}

/// @nodoc
class __$$SlotSymbolModelImplCopyWithImpl<$Res>
    extends _$SlotSymbolModelCopyWithImpl<$Res, _$SlotSymbolModelImpl>
    implements _$$SlotSymbolModelImplCopyWith<$Res> {
  __$$SlotSymbolModelImplCopyWithImpl(
      _$SlotSymbolModelImpl _value, $Res Function(_$SlotSymbolModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotSymbolModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? iconAsset = null,
    Object? weight = null,
    Object? payoutTable = null,
  }) {
    return _then(_$SlotSymbolModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      iconAsset: null == iconAsset
          ? _value.iconAsset
          : iconAsset // ignore: cast_nullable_to_non_nullable
              as String,
      weight: null == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as int,
      payoutTable: null == payoutTable
          ? _value._payoutTable
          : payoutTable // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotSymbolModelImpl implements _SlotSymbolModel {
  const _$SlotSymbolModelImpl(
      {required this.id,
      required this.iconAsset,
      required this.weight,
      required final Map<String, double> payoutTable})
      : _payoutTable = payoutTable;

  factory _$SlotSymbolModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotSymbolModelImplFromJson(json);

  @override
  final String id;
  @override
  final String iconAsset;
  @override
  final int weight;
// key: number of matching symbols (e.g. "2" or "3")
// value: multiplier
  final Map<String, double> _payoutTable;
// key: number of matching symbols (e.g. "2" or "3")
// value: multiplier
  @override
  Map<String, double> get payoutTable {
    if (_payoutTable is EqualUnmodifiableMapView) return _payoutTable;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_payoutTable);
  }

  @override
  String toString() {
    return 'SlotSymbolModel(id: $id, iconAsset: $iconAsset, weight: $weight, payoutTable: $payoutTable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotSymbolModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.iconAsset, iconAsset) ||
                other.iconAsset == iconAsset) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality()
                .equals(other._payoutTable, _payoutTable));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, iconAsset, weight,
      const DeepCollectionEquality().hash(_payoutTable));

  /// Create a copy of SlotSymbolModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotSymbolModelImplCopyWith<_$SlotSymbolModelImpl> get copyWith =>
      __$$SlotSymbolModelImplCopyWithImpl<_$SlotSymbolModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotSymbolModelImplToJson(
      this,
    );
  }
}

abstract class _SlotSymbolModel implements SlotSymbolModel {
  const factory _SlotSymbolModel(
      {required final String id,
      required final String iconAsset,
      required final int weight,
      required final Map<String, double> payoutTable}) = _$SlotSymbolModelImpl;

  factory _SlotSymbolModel.fromJson(Map<String, dynamic> json) =
      _$SlotSymbolModelImpl.fromJson;

  @override
  String get id;
  @override
  String get iconAsset;
  @override
  int get weight; // key: number of matching symbols (e.g. "2" or "3")
// value: multiplier
  @override
  Map<String, double> get payoutTable;

  /// Create a copy of SlotSymbolModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotSymbolModelImplCopyWith<_$SlotSymbolModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
