// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'betting_session_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BettingSessionModel _$BettingSessionModelFromJson(Map<String, dynamic> json) {
  return _BettingSessionModel.fromJson(json);
}

/// @nodoc
mixin _$BettingSessionModel {
  String get sessionId => throw _privateConstructorUsedError;
  int get sessionNumber => throw _privateConstructorUsedError;
  SessionStatus get status => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;
  DateTime? get lockedAt => throw _privateConstructorUsedError;
  DateTime? get settledAt => throw _privateConstructorUsedError;
  String? get result =>
      throw _privateConstructorUsedError; // null, 'over', 'under'
  bool get isAdminOverride => throw _privateConstructorUsedError;
  double get totalOverBets => throw _privateConstructorUsedError;
  double get totalUnderBets => throw _privateConstructorUsedError;
  double get oddsOver => throw _privateConstructorUsedError;
  double get oddsUnder => throw _privateConstructorUsedError;
  double get overUnderLine => throw _privateConstructorUsedError;

  /// Serializes this BettingSessionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BettingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BettingSessionModelCopyWith<BettingSessionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BettingSessionModelCopyWith<$Res> {
  factory $BettingSessionModelCopyWith(
          BettingSessionModel value, $Res Function(BettingSessionModel) then) =
      _$BettingSessionModelCopyWithImpl<$Res, BettingSessionModel>;
  @useResult
  $Res call(
      {String sessionId,
      int sessionNumber,
      SessionStatus status,
      DateTime startedAt,
      DateTime? lockedAt,
      DateTime? settledAt,
      String? result,
      bool isAdminOverride,
      double totalOverBets,
      double totalUnderBets,
      double oddsOver,
      double oddsUnder,
      double overUnderLine});
}

/// @nodoc
class _$BettingSessionModelCopyWithImpl<$Res, $Val extends BettingSessionModel>
    implements $BettingSessionModelCopyWith<$Res> {
  _$BettingSessionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BettingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionNumber = null,
    Object? status = null,
    Object? startedAt = null,
    Object? lockedAt = freezed,
    Object? settledAt = freezed,
    Object? result = freezed,
    Object? isAdminOverride = null,
    Object? totalOverBets = null,
    Object? totalUnderBets = null,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? overUnderLine = null,
  }) {
    return _then(_value.copyWith(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionNumber: null == sessionNumber
          ? _value.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lockedAt: freezed == lockedAt
          ? _value.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      isAdminOverride: null == isAdminOverride
          ? _value.isAdminOverride
          : isAdminOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOverBets: null == totalOverBets
          ? _value.totalOverBets
          : totalOverBets // ignore: cast_nullable_to_non_nullable
              as double,
      totalUnderBets: null == totalUnderBets
          ? _value.totalUnderBets
          : totalUnderBets // ignore: cast_nullable_to_non_nullable
              as double,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      overUnderLine: null == overUnderLine
          ? _value.overUnderLine
          : overUnderLine // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BettingSessionModelImplCopyWith<$Res>
    implements $BettingSessionModelCopyWith<$Res> {
  factory _$$BettingSessionModelImplCopyWith(_$BettingSessionModelImpl value,
          $Res Function(_$BettingSessionModelImpl) then) =
      __$$BettingSessionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String sessionId,
      int sessionNumber,
      SessionStatus status,
      DateTime startedAt,
      DateTime? lockedAt,
      DateTime? settledAt,
      String? result,
      bool isAdminOverride,
      double totalOverBets,
      double totalUnderBets,
      double oddsOver,
      double oddsUnder,
      double overUnderLine});
}

/// @nodoc
class __$$BettingSessionModelImplCopyWithImpl<$Res>
    extends _$BettingSessionModelCopyWithImpl<$Res, _$BettingSessionModelImpl>
    implements _$$BettingSessionModelImplCopyWith<$Res> {
  __$$BettingSessionModelImplCopyWithImpl(_$BettingSessionModelImpl _value,
      $Res Function(_$BettingSessionModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BettingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sessionId = null,
    Object? sessionNumber = null,
    Object? status = null,
    Object? startedAt = null,
    Object? lockedAt = freezed,
    Object? settledAt = freezed,
    Object? result = freezed,
    Object? isAdminOverride = null,
    Object? totalOverBets = null,
    Object? totalUnderBets = null,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? overUnderLine = null,
  }) {
    return _then(_$BettingSessionModelImpl(
      sessionId: null == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String,
      sessionNumber: null == sessionNumber
          ? _value.sessionNumber
          : sessionNumber // ignore: cast_nullable_to_non_nullable
              as int,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      startedAt: null == startedAt
          ? _value.startedAt
          : startedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lockedAt: freezed == lockedAt
          ? _value.lockedAt
          : lockedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      settledAt: freezed == settledAt
          ? _value.settledAt
          : settledAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as String?,
      isAdminOverride: null == isAdminOverride
          ? _value.isAdminOverride
          : isAdminOverride // ignore: cast_nullable_to_non_nullable
              as bool,
      totalOverBets: null == totalOverBets
          ? _value.totalOverBets
          : totalOverBets // ignore: cast_nullable_to_non_nullable
              as double,
      totalUnderBets: null == totalUnderBets
          ? _value.totalUnderBets
          : totalUnderBets // ignore: cast_nullable_to_non_nullable
              as double,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      overUnderLine: null == overUnderLine
          ? _value.overUnderLine
          : overUnderLine // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BettingSessionModelImpl implements _BettingSessionModel {
  const _$BettingSessionModelImpl(
      {required this.sessionId,
      required this.sessionNumber,
      required this.status,
      required this.startedAt,
      this.lockedAt,
      this.settledAt,
      this.result,
      this.isAdminOverride = false,
      this.totalOverBets = 0.0,
      this.totalUnderBets = 0.0,
      this.oddsOver = 1.85,
      this.oddsUnder = 1.95,
      this.overUnderLine = 2.5});

  factory _$BettingSessionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BettingSessionModelImplFromJson(json);

  @override
  final String sessionId;
  @override
  final int sessionNumber;
  @override
  final SessionStatus status;
  @override
  final DateTime startedAt;
  @override
  final DateTime? lockedAt;
  @override
  final DateTime? settledAt;
  @override
  final String? result;
// null, 'over', 'under'
  @override
  @JsonKey()
  final bool isAdminOverride;
  @override
  @JsonKey()
  final double totalOverBets;
  @override
  @JsonKey()
  final double totalUnderBets;
  @override
  @JsonKey()
  final double oddsOver;
  @override
  @JsonKey()
  final double oddsUnder;
  @override
  @JsonKey()
  final double overUnderLine;

  @override
  String toString() {
    return 'BettingSessionModel(sessionId: $sessionId, sessionNumber: $sessionNumber, status: $status, startedAt: $startedAt, lockedAt: $lockedAt, settledAt: $settledAt, result: $result, isAdminOverride: $isAdminOverride, totalOverBets: $totalOverBets, totalUnderBets: $totalUnderBets, oddsOver: $oddsOver, oddsUnder: $oddsUnder, overUnderLine: $overUnderLine)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BettingSessionModelImpl &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.sessionNumber, sessionNumber) ||
                other.sessionNumber == sessionNumber) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt) &&
            (identical(other.lockedAt, lockedAt) ||
                other.lockedAt == lockedAt) &&
            (identical(other.settledAt, settledAt) ||
                other.settledAt == settledAt) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.isAdminOverride, isAdminOverride) ||
                other.isAdminOverride == isAdminOverride) &&
            (identical(other.totalOverBets, totalOverBets) ||
                other.totalOverBets == totalOverBets) &&
            (identical(other.totalUnderBets, totalUnderBets) ||
                other.totalUnderBets == totalUnderBets) &&
            (identical(other.oddsOver, oddsOver) ||
                other.oddsOver == oddsOver) &&
            (identical(other.oddsUnder, oddsUnder) ||
                other.oddsUnder == oddsUnder) &&
            (identical(other.overUnderLine, overUnderLine) ||
                other.overUnderLine == overUnderLine));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      sessionId,
      sessionNumber,
      status,
      startedAt,
      lockedAt,
      settledAt,
      result,
      isAdminOverride,
      totalOverBets,
      totalUnderBets,
      oddsOver,
      oddsUnder,
      overUnderLine);

  /// Create a copy of BettingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BettingSessionModelImplCopyWith<_$BettingSessionModelImpl> get copyWith =>
      __$$BettingSessionModelImplCopyWithImpl<_$BettingSessionModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BettingSessionModelImplToJson(
      this,
    );
  }
}

abstract class _BettingSessionModel implements BettingSessionModel {
  const factory _BettingSessionModel(
      {required final String sessionId,
      required final int sessionNumber,
      required final SessionStatus status,
      required final DateTime startedAt,
      final DateTime? lockedAt,
      final DateTime? settledAt,
      final String? result,
      final bool isAdminOverride,
      final double totalOverBets,
      final double totalUnderBets,
      final double oddsOver,
      final double oddsUnder,
      final double overUnderLine}) = _$BettingSessionModelImpl;

  factory _BettingSessionModel.fromJson(Map<String, dynamic> json) =
      _$BettingSessionModelImpl.fromJson;

  @override
  String get sessionId;
  @override
  int get sessionNumber;
  @override
  SessionStatus get status;
  @override
  DateTime get startedAt;
  @override
  DateTime? get lockedAt;
  @override
  DateTime? get settledAt;
  @override
  String? get result; // null, 'over', 'under'
  @override
  bool get isAdminOverride;
  @override
  double get totalOverBets;
  @override
  double get totalUnderBets;
  @override
  double get oddsOver;
  @override
  double get oddsUnder;
  @override
  double get overUnderLine;

  /// Create a copy of BettingSessionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BettingSessionModelImplCopyWith<_$BettingSessionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
