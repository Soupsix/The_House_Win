// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BetModel _$BetModelFromJson(Map<String, dynamic> json) {
  return _BetModel.fromJson(json);
}

/// @nodoc
mixin _$BetModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String? get matchId => throw _privateConstructorUsedError;
  String? get homeTeam => throw _privateConstructorUsedError;
  String? get awayTeam => throw _privateConstructorUsedError;
  String? get sessionId => throw _privateConstructorUsedError;
  int? get sessionNumber => throw _privateConstructorUsedError;
  BetChoice get choice => throw _privateConstructorUsedError;
  double get amount => throw _privateConstructorUsedError;
  double get oddsAtTime => throw _privateConstructorUsedError;
  double get payout => throw _privateConstructorUsedError;
  BetStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get settledAt => throw _privateConstructorUsedError;

  /// Serializes this BetModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BetModelCopyWith<BetModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BetModelCopyWith<$Res> {
  factory $BetModelCopyWith(BetModel value, $Res Function(BetModel) then) =
      _$BetModelCopyWithImpl<$Res, BetModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? matchId,
      String? homeTeam,
      String? awayTeam,
      String? sessionId,
      int? sessionNumber,
      BetChoice choice,
      double amount,
      double oddsAtTime,
      double payout,
      BetStatus status,
      DateTime createdAt,
      DateTime? settledAt});
}

/// @nodoc
class _$BetModelCopyWithImpl<$Res, $Val extends BetModel>
    implements $BetModelCopyWith<$Res> {
  _$BetModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? matchId = freezed,
    Object? homeTeam = freezed,
    Object? awayTeam = freezed,
    Object? sessionId = freezed,
    Object? sessionNumber = freezed,
    Object? choice = null,
    Object? amount = null,
    Object? oddsAtTime = null,
    Object? payout = null,
    Object? status = null,
    Object? createdAt = null,
    Object? settledAt = freezed,
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
      matchId: freezed == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String?,
      homeTeam: freezed == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      awayTeam: freezed == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionNumber: freezed == sessionNumber
          ? _value.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      choice: null == choice
          ? _value.choice
          : choice // ignore: cast_nullable_to_non_nullable
              as BetChoice,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      oddsAtTime: null == oddsAtTime
          ? _value.oddsAtTime
          : oddsAtTime // ignore: cast_nullable_to_non_nullable
              as double,
      payout: null == payout
          ? _value.payout
          : payout // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BetStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BetModelImplCopyWith<$Res>
    implements $BetModelCopyWith<$Res> {
  factory _$$BetModelImplCopyWith(
          _$BetModelImpl value, $Res Function(_$BetModelImpl) then) =
      __$$BetModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? matchId,
      String? homeTeam,
      String? awayTeam,
      String? sessionId,
      int? sessionNumber,
      BetChoice choice,
      double amount,
      double oddsAtTime,
      double payout,
      BetStatus status,
      DateTime createdAt,
      DateTime? settledAt});
}

/// @nodoc
class __$$BetModelImplCopyWithImpl<$Res>
    extends _$BetModelCopyWithImpl<$Res, _$BetModelImpl>
    implements _$$BetModelImplCopyWith<$Res> {
  __$$BetModelImplCopyWithImpl(
      _$BetModelImpl _value, $Res Function(_$BetModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BetModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? matchId = freezed,
    Object? homeTeam = freezed,
    Object? awayTeam = freezed,
    Object? sessionId = freezed,
    Object? sessionNumber = freezed,
    Object? choice = null,
    Object? amount = null,
    Object? oddsAtTime = null,
    Object? payout = null,
    Object? status = null,
    Object? createdAt = null,
    Object? settledAt = freezed,
  }) {
    return _then(_$BetModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: freezed == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String?,
      homeTeam: freezed == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      awayTeam: freezed == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionNumber: freezed == sessionNumber
          ? _value.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      choice: null == choice
          ? _value.choice
          : choice // ignore: cast_nullable_to_non_nullable
              as BetChoice,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      oddsAtTime: null == oddsAtTime
          ? _value.oddsAtTime
          : oddsAtTime // ignore: cast_nullable_to_non_nullable
              as double,
      payout: null == payout
          ? _value.payout
          : payout // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as BetStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BetModelImpl implements _BetModel {
  const _$BetModelImpl(
      {required this.id,
      required this.userId,
      this.matchId,
      this.homeTeam,
      this.awayTeam,
      this.sessionId,
      this.sessionNumber,
      required this.choice,
      required this.amount,
      required this.oddsAtTime,
      this.payout = 0.0,
      required this.status,
      required this.createdAt,
      this.settledAt});

  factory _$BetModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BetModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? matchId;
  @override
  final String? homeTeam;
  @override
  final String? awayTeam;
  @override
  final String? sessionId;
  @override
  final int? sessionNumber;
  @override
  final BetChoice choice;
  @override
  final double amount;
  @override
  final double oddsAtTime;
  @override
  @JsonKey()
  final double payout;
  @override
  final BetStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? settledAt;

  @override
  String toString() {
    return 'BetModel(id: $id, userId: $userId, matchId: $matchId, homeTeam: $homeTeam, awayTeam: $awayTeam, sessionId: $sessionId, sessionNumber: $sessionNumber, choice: $choice, amount: $amount, oddsAtTime: $oddsAtTime, payout: $payout, status: $status, createdAt: $createdAt, settledAt: $settledAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BetModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.homeTeam, homeTeam) ||
                other.homeTeam == homeTeam) &&
            (identical(other.awayTeam, awayTeam) ||
                other.awayTeam == awayTeam) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.sessionNumber, sessionNumber) ||
                other.sessionNumber == sessionNumber) &&
            (identical(other.choice, choice) || other.choice == choice) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.oddsAtTime, oddsAtTime) ||
                other.oddsAtTime == oddsAtTime) &&
            (identical(other.payout, payout) || other.payout == payout) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.settledAt, settledAt) ||
                other.settledAt == settledAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      matchId,
      homeTeam,
      awayTeam,
      sessionId,
      sessionNumber,
      choice,
      amount,
      oddsAtTime,
      payout,
      status,
      createdAt,
      settledAt);

  /// Create a copy of BetModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BetModelImplCopyWith<_$BetModelImpl> get copyWith =>
      __$$BetModelImplCopyWithImpl<_$BetModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BetModelImplToJson(
      this,
    );
  }
}

abstract class _BetModel implements BetModel {
  const factory _BetModel(
      {required final String id,
      required final String userId,
      final String? matchId,
      final String? homeTeam,
      final String? awayTeam,
      final String? sessionId,
      final int? sessionNumber,
      required final BetChoice choice,
      required final double amount,
      required final double oddsAtTime,
      final double payout,
      required final BetStatus status,
      required final DateTime createdAt,
      final DateTime? settledAt}) = _$BetModelImpl;

  factory _BetModel.fromJson(Map<String, dynamic> json) =
      _$BetModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String? get matchId;
  @override
  String? get homeTeam;
  @override
  String? get awayTeam;
  @override
  String? get sessionId;
  @override
  int? get sessionNumber;
  @override
  BetChoice get choice;
  @override
  double get amount;
  @override
  double get oddsAtTime;
  @override
  double get payout;
  @override
  BetStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get settledAt;

  /// Create a copy of BetModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BetModelImplCopyWith<_$BetModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
