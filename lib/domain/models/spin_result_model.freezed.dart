// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spin_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpinResultModel _$SpinResultModelFromJson(Map<String, dynamic> json) {
  return _SpinResultModel.fromJson(json);
}

/// @nodoc
mixin _$SpinResultModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  double get betAmount => throw _privateConstructorUsedError;
  String get segmentId =>
      throw _privateConstructorUsedError; // segment nào trúng
  double get multiplier => throw _privateConstructorUsedError;
  double get payout => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String? get transactionId => throw _privateConstructorUsedError;

  /// Serializes this SpinResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpinResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpinResultModelCopyWith<SpinResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpinResultModelCopyWith<$Res> {
  factory $SpinResultModelCopyWith(
          SpinResultModel value, $Res Function(SpinResultModel) then) =
      _$SpinResultModelCopyWithImpl<$Res, SpinResultModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      double betAmount,
      String segmentId,
      double multiplier,
      double payout,
      DateTime createdAt,
      String? transactionId});
}

/// @nodoc
class _$SpinResultModelCopyWithImpl<$Res, $Val extends SpinResultModel>
    implements $SpinResultModelCopyWith<$Res> {
  _$SpinResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpinResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? betAmount = null,
    Object? segmentId = null,
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
      segmentId: null == segmentId
          ? _value.segmentId
          : segmentId // ignore: cast_nullable_to_non_nullable
              as String,
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
abstract class _$$SpinResultModelImplCopyWith<$Res>
    implements $SpinResultModelCopyWith<$Res> {
  factory _$$SpinResultModelImplCopyWith(_$SpinResultModelImpl value,
          $Res Function(_$SpinResultModelImpl) then) =
      __$$SpinResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      double betAmount,
      String segmentId,
      double multiplier,
      double payout,
      DateTime createdAt,
      String? transactionId});
}

/// @nodoc
class __$$SpinResultModelImplCopyWithImpl<$Res>
    extends _$SpinResultModelCopyWithImpl<$Res, _$SpinResultModelImpl>
    implements _$$SpinResultModelImplCopyWith<$Res> {
  __$$SpinResultModelImplCopyWithImpl(
      _$SpinResultModelImpl _value, $Res Function(_$SpinResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpinResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? betAmount = null,
    Object? segmentId = null,
    Object? multiplier = null,
    Object? payout = null,
    Object? createdAt = null,
    Object? transactionId = freezed,
  }) {
    return _then(_$SpinResultModelImpl(
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
      segmentId: null == segmentId
          ? _value.segmentId
          : segmentId // ignore: cast_nullable_to_non_nullable
              as String,
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
class _$SpinResultModelImpl implements _SpinResultModel {
  const _$SpinResultModelImpl(
      {required this.id,
      required this.userId,
      required this.betAmount,
      required this.segmentId,
      required this.multiplier,
      required this.payout,
      required this.createdAt,
      this.transactionId});

  factory _$SpinResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpinResultModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final double betAmount;
  @override
  final String segmentId;
// segment nào trúng
  @override
  final double multiplier;
  @override
  final double payout;
  @override
  final DateTime createdAt;
  @override
  final String? transactionId;

  @override
  String toString() {
    return 'SpinResultModel(id: $id, userId: $userId, betAmount: $betAmount, segmentId: $segmentId, multiplier: $multiplier, payout: $payout, createdAt: $createdAt, transactionId: $transactionId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpinResultModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.betAmount, betAmount) ||
                other.betAmount == betAmount) &&
            (identical(other.segmentId, segmentId) ||
                other.segmentId == segmentId) &&
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
  int get hashCode => Object.hash(runtimeType, id, userId, betAmount, segmentId,
      multiplier, payout, createdAt, transactionId);

  /// Create a copy of SpinResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpinResultModelImplCopyWith<_$SpinResultModelImpl> get copyWith =>
      __$$SpinResultModelImplCopyWithImpl<_$SpinResultModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpinResultModelImplToJson(
      this,
    );
  }
}

abstract class _SpinResultModel implements SpinResultModel {
  const factory _SpinResultModel(
      {required final String id,
      required final String userId,
      required final double betAmount,
      required final String segmentId,
      required final double multiplier,
      required final double payout,
      required final DateTime createdAt,
      final String? transactionId}) = _$SpinResultModelImpl;

  factory _SpinResultModel.fromJson(Map<String, dynamic> json) =
      _$SpinResultModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  double get betAmount;
  @override
  String get segmentId; // segment nào trúng
  @override
  double get multiplier;
  @override
  double get payout;
  @override
  DateTime get createdAt;
  @override
  String? get transactionId;

  /// Create a copy of SpinResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpinResultModelImplCopyWith<_$SpinResultModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
