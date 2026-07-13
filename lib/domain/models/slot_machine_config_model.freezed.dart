// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_machine_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlotMachineConfigModel _$SlotMachineConfigModelFromJson(
    Map<String, dynamic> json) {
  return _SlotMachineConfigModel.fromJson(json);
}

/// @nodoc
mixin _$SlotMachineConfigModel {
  String get id => throw _privateConstructorUsedError;
  List<SlotSymbolModel> get symbols => throw _privateConstructorUsedError;
  int get reelCount => throw _privateConstructorUsedError; // default 3
  double get fixedBet =>
      throw _privateConstructorUsedError; // or minBet/maxBet if we allow flexible betting
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this SlotMachineConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlotMachineConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotMachineConfigModelCopyWith<SlotMachineConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotMachineConfigModelCopyWith<$Res> {
  factory $SlotMachineConfigModelCopyWith(SlotMachineConfigModel value,
          $Res Function(SlotMachineConfigModel) then) =
      _$SlotMachineConfigModelCopyWithImpl<$Res, SlotMachineConfigModel>;
  @useResult
  $Res call(
      {String id,
      List<SlotSymbolModel> symbols,
      int reelCount,
      double fixedBet,
      bool isActive});
}

/// @nodoc
class _$SlotMachineConfigModelCopyWithImpl<$Res,
        $Val extends SlotMachineConfigModel>
    implements $SlotMachineConfigModelCopyWith<$Res> {
  _$SlotMachineConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotMachineConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbols = null,
    Object? reelCount = null,
    Object? fixedBet = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbols: null == symbols
          ? _value.symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<SlotSymbolModel>,
      reelCount: null == reelCount
          ? _value.reelCount
          : reelCount // ignore: cast_nullable_to_non_nullable
              as int,
      fixedBet: null == fixedBet
          ? _value.fixedBet
          : fixedBet // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SlotMachineConfigModelImplCopyWith<$Res>
    implements $SlotMachineConfigModelCopyWith<$Res> {
  factory _$$SlotMachineConfigModelImplCopyWith(
          _$SlotMachineConfigModelImpl value,
          $Res Function(_$SlotMachineConfigModelImpl) then) =
      __$$SlotMachineConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<SlotSymbolModel> symbols,
      int reelCount,
      double fixedBet,
      bool isActive});
}

/// @nodoc
class __$$SlotMachineConfigModelImplCopyWithImpl<$Res>
    extends _$SlotMachineConfigModelCopyWithImpl<$Res,
        _$SlotMachineConfigModelImpl>
    implements _$$SlotMachineConfigModelImplCopyWith<$Res> {
  __$$SlotMachineConfigModelImplCopyWithImpl(
      _$SlotMachineConfigModelImpl _value,
      $Res Function(_$SlotMachineConfigModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotMachineConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? symbols = null,
    Object? reelCount = null,
    Object? fixedBet = null,
    Object? isActive = null,
  }) {
    return _then(_$SlotMachineConfigModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      symbols: null == symbols
          ? _value._symbols
          : symbols // ignore: cast_nullable_to_non_nullable
              as List<SlotSymbolModel>,
      reelCount: null == reelCount
          ? _value.reelCount
          : reelCount // ignore: cast_nullable_to_non_nullable
              as int,
      fixedBet: null == fixedBet
          ? _value.fixedBet
          : fixedBet // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotMachineConfigModelImpl implements _SlotMachineConfigModel {
  const _$SlotMachineConfigModelImpl(
      {required this.id,
      required final List<SlotSymbolModel> symbols,
      required this.reelCount,
      required this.fixedBet,
      this.isActive = true})
      : _symbols = symbols;

  factory _$SlotMachineConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotMachineConfigModelImplFromJson(json);

  @override
  final String id;
  final List<SlotSymbolModel> _symbols;
  @override
  List<SlotSymbolModel> get symbols {
    if (_symbols is EqualUnmodifiableListView) return _symbols;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_symbols);
  }

  @override
  final int reelCount;
// default 3
  @override
  final double fixedBet;
// or minBet/maxBet if we allow flexible betting
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'SlotMachineConfigModel(id: $id, symbols: $symbols, reelCount: $reelCount, fixedBet: $fixedBet, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotMachineConfigModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._symbols, _symbols) &&
            (identical(other.reelCount, reelCount) ||
                other.reelCount == reelCount) &&
            (identical(other.fixedBet, fixedBet) ||
                other.fixedBet == fixedBet) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      const DeepCollectionEquality().hash(_symbols),
      reelCount,
      fixedBet,
      isActive);

  /// Create a copy of SlotMachineConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotMachineConfigModelImplCopyWith<_$SlotMachineConfigModelImpl>
      get copyWith => __$$SlotMachineConfigModelImplCopyWithImpl<
          _$SlotMachineConfigModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotMachineConfigModelImplToJson(
      this,
    );
  }
}

abstract class _SlotMachineConfigModel implements SlotMachineConfigModel {
  const factory _SlotMachineConfigModel(
      {required final String id,
      required final List<SlotSymbolModel> symbols,
      required final int reelCount,
      required final double fixedBet,
      final bool isActive}) = _$SlotMachineConfigModelImpl;

  factory _SlotMachineConfigModel.fromJson(Map<String, dynamic> json) =
      _$SlotMachineConfigModelImpl.fromJson;

  @override
  String get id;
  @override
  List<SlotSymbolModel> get symbols;
  @override
  int get reelCount; // default 3
  @override
  double get fixedBet; // or minBet/maxBet if we allow flexible betting
  @override
  bool get isActive;

  /// Create a copy of SlotMachineConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotMachineConfigModelImplCopyWith<_$SlotMachineConfigModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
