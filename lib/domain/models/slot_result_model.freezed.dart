// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SlotResultModel _$SlotResultModelFromJson(Map<String, dynamic> json) {
  return _SlotResultModel.fromJson(json);
}

/// @nodoc
mixin _$SlotResultModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get betAmount => throw _privateConstructorUsedError;
  List<String> get reelSymbolIds =>
      throw _privateConstructorUsedError; // e.g. ["cherry", "cherry", "lemon"]
  double get multiplier => throw _privateConstructorUsedError; // 0 if no win
  double get payout =>
      throw _privateConstructorUsedError; // betAmount * multiplier
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this SlotResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SlotResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotResultModelCopyWith<SlotResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotResultModelCopyWith<$Res> {
  factory $SlotResultModelCopyWith(
          SlotResultModel value, $Res Function(SlotResultModel) then) =
      _$SlotResultModelCopyWithImpl<$Res, SlotResultModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double betAmount,
      List<String> reelSymbolIds,
      double multiplier,
      double payout,
      DateTime createdAt,
      String? transactionId});
}

/// @nodoc
class _$SlotResultModelCopyWithImpl<$Res, $Val extends SlotResultModel>
    implements $SlotResultModelCopyWith<$Res> {
  _$SlotResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? betAmount = null,
    Object? reelSymbolIds = null,
    Object? multiplier = null,
    Object? payout = null,
    Object? createdAt = null,
    Object? transactionId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      reelSymbolIds: null == reelSymbolIds
          ? _value.reelSymbolIds
          : reelSymbolIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      payout: null == payout
          ? _value.payout
          : payout // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SlotResultModelImplCopyWith<$Res>
    implements $SlotResultModelCopyWith<$Res> {
  factory _$$SlotResultModelImplCopyWith(_$SlotResultModelImpl value,
          $Res Function(_$SlotResultModelImpl) then) =
      __$$SlotResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double betAmount,
      List<String> reelSymbolIds,
      double multiplier,
      double payout,
      DateTime createdAt,
      String? transactionId});
}

/// @nodoc
class __$$SlotResultModelImplCopyWithImpl<$Res>
    extends _$SlotResultModelCopyWithImpl<$Res, _$SlotResultModelImpl>
    implements _$$SlotResultModelImplCopyWith<$Res> {
  __$$SlotResultModelImplCopyWithImpl(
      _$SlotResultModelImpl _value, $Res Function(_$SlotResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? betAmount = null,
    Object? reelSymbolIds = null,
    Object? multiplier = null,
    Object? payout = null,
    Object? createdAt = null,
    Object? transactionId = freezed,
  }) {
    return _then(_$SlotResultModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      reelSymbolIds: null == reelSymbolIds
          ? _value._reelSymbolIds
          : reelSymbolIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      payout: null == payout
          ? _value.payout
          : payout // ignore: cast_nullable_to_non_nullable
              as double,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionId: freezed == transactionId
          ? _value.transactionId
          : transactionId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SlotResultModelImpl implements _SlotResultModel {
  const _$SlotResultModelImpl(
      {required this.id,
      required this.userId,
      required this.betAmount,
      required final List<String> reelSymbolIds,
      required this.multiplier,
      required this.payout,
      required this.createdAt,
      this.transactionId})
      : _reelSymbolIds = reelSymbolIds;

  factory _$SlotResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SlotResultModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double betAmount;
  final List<String> _reelSymbolIds;
  @override
  List<String> get reelSymbolIds {
    if (_reelSymbolIds is EqualUnmodifiableListView) return _reelSymbolIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reelSymbolIds);
  }

// e.g. ["cherry", "cherry", "lemon"]
  @override
  final double multiplier;
// 0 if no win
  @override
  final double payout;
// betAmount * multiplier
  @override
  final DateTime createdAt;
  @override
  final String? transactionId;

  @override
  String toString() {
    return 'SlotResultModel(id: $id, userId: $userId, betAmount: $betAmount, reelSymbolIds: $reelSymbolIds, multiplier: $multiplier, payout: $payout, createdAt: $createdAt, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.betAmount, betAmount) ||
                other.betAmount == betAmount) &&
            const DeepCollectionEquality()
                .equals(other._reelSymbolIds, _reelSymbolIds) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.payout, payout) || other.payout == payout) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.transactionId, transactionId) ||
                other.transactionId == transactionId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      betAmount,
      const DeepCollectionEquality().hash(_reelSymbolIds),
      multiplier,
      payout,
      createdAt,
      transactionId);

  /// Create a copy of SlotResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotResultModelImplCopyWith<_$SlotResultModelImpl> get copyWith =>
      __$$SlotResultModelImplCopyWithImpl<_$SlotResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SlotResultModelImplToJson(
      this,
    );
  }
}

abstract class _SlotResultModel implements SlotResultModel {
  const factory _SlotResultModel(
      {required final String id,
      required final String userId,
      required final double betAmount,
      required final List<String> reelSymbolIds,
      required final double multiplier,
      required final double payout,
      required final DateTime createdAt,
      final String? transactionId}) = _$SlotResultModelImpl;

  factory _SlotResultModel.fromJson(Map<String, dynamic> json) =
      _$SlotResultModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get betAmount;
  @override
  List<String> get reelSymbolIds; // e.g. ["cherry", "cherry", "lemon"]
  @override
  double get multiplier; // 0 if no win
  @override
  double get payout; // betAmount * multiplier
  @override
  DateTime get createdAt;
  @override
  String? get transactionId;

  /// Create a copy of SlotResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotResultModelImplCopyWith<_$SlotResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
