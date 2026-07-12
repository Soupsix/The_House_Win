// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MatchModel _$MatchModelFromJson(Map<String, dynamic> json) {
  return _MatchModel.fromJson(json);
}

/// @nodoc
mixin _$MatchModel {
  String get id => throw _privateConstructorUsedError;
  String get homeTeam => throw _privateConstructorUsedError;
  String get awayTeam => throw _privateConstructorUsedError;
  DateTime get utcDate => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  int get scoreHome => throw _privateConstructorUsedError;
  int get scoreAway => throw _privateConstructorUsedError;
  MatchResult? get result => throw _privateConstructorUsedError;
  double get oddsOver => throw _privateConstructorUsedError;
  double get oddsUnder => throw _privateConstructorUsedError;
  double get oddsDraw => throw _privateConstructorUsedError;
  double get overUnderLine => throw _privateConstructorUsedError;
  bool get isSimulated => throw _privateConstructorUsedError;
  String get leagueName => throw _privateConstructorUsedError;
  String get homeTeamLogo => throw _privateConstructorUsedError;
  String get awayTeamLogo => throw _privateConstructorUsedError;

  /// Serializes this MatchModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchModelCopyWith<MatchModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchModelCopyWith<$Res> {
  factory $MatchModelCopyWith(
          MatchModel value, $Res Function(MatchModel) then) =
      _$MatchModelCopyWithImpl<$Res, MatchModel>;
  @useResult
  $Res call(
      {String id,
      String homeTeam,
      String awayTeam,
      DateTime utcDate,
      MatchStatus status,
      int scoreHome,
      int scoreAway,
      MatchResult? result,
      double oddsOver,
      double oddsUnder,
      double oddsDraw,
      double overUnderLine,
      bool isSimulated,
      String leagueName,
      String homeTeamLogo,
      String awayTeamLogo});
}

/// @nodoc
class _$MatchModelCopyWithImpl<$Res, $Val extends MatchModel>
    implements $MatchModelCopyWith<$Res> {
  _$MatchModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? utcDate = null,
    Object? status = null,
    Object? scoreHome = null,
    Object? scoreAway = null,
    Object? result = freezed,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? oddsDraw = null,
    Object? overUnderLine = null,
    Object? isSimulated = null,
    Object? leagueName = null,
    Object? homeTeamLogo = null,
    Object? awayTeamLogo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String,
      utcDate: null == utcDate
          ? _value.utcDate
          : utcDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      scoreHome: null == scoreHome
          ? _value.scoreHome
          : scoreHome // ignore: cast_nullable_to_non_nullable
              as int,
      scoreAway: null == scoreAway
          ? _value.scoreAway
          : scoreAway // ignore: cast_nullable_to_non_nullable
              as int,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as MatchResult?,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      oddsDraw: null == oddsDraw
          ? _value.oddsDraw
          : oddsDraw // ignore: cast_nullable_to_non_nullable
              as double,
      overUnderLine: null == overUnderLine
          ? _value.overUnderLine
          : overUnderLine // ignore: cast_nullable_to_non_nullable
              as double,
      isSimulated: null == isSimulated
          ? _value.isSimulated
          : isSimulated // ignore: cast_nullable_to_non_nullable
              as bool,
      leagueName: null == leagueName
          ? _value.leagueName
          : leagueName // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeamLogo: null == homeTeamLogo
          ? _value.homeTeamLogo
          : homeTeamLogo // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeamLogo: null == awayTeamLogo
          ? _value.awayTeamLogo
          : awayTeamLogo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchModelImplCopyWith<$Res>
    implements $MatchModelCopyWith<$Res> {
  factory _$$MatchModelImplCopyWith(
          _$MatchModelImpl value, $Res Function(_$MatchModelImpl) then) =
      __$$MatchModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String homeTeam,
      String awayTeam,
      DateTime utcDate,
      MatchStatus status,
      int scoreHome,
      int scoreAway,
      MatchResult? result,
      double oddsOver,
      double oddsUnder,
      double oddsDraw,
      double overUnderLine,
      bool isSimulated,
      String leagueName,
      String homeTeamLogo,
      String awayTeamLogo});
}

/// @nodoc
class __$$MatchModelImplCopyWithImpl<$Res>
    extends _$MatchModelCopyWithImpl<$Res, _$MatchModelImpl>
    implements _$$MatchModelImplCopyWith<$Res> {
  __$$MatchModelImplCopyWithImpl(
      _$MatchModelImpl _value, $Res Function(_$MatchModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? homeTeam = null,
    Object? awayTeam = null,
    Object? utcDate = null,
    Object? status = null,
    Object? scoreHome = null,
    Object? scoreAway = null,
    Object? result = freezed,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? oddsDraw = null,
    Object? overUnderLine = null,
    Object? isSimulated = null,
    Object? leagueName = null,
    Object? homeTeamLogo = null,
    Object? awayTeamLogo = null,
  }) {
    return _then(_$MatchModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeam: null == homeTeam
          ? _value.homeTeam
          : homeTeam // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeam: null == awayTeam
          ? _value.awayTeam
          : awayTeam // ignore: cast_nullable_to_non_nullable
              as String,
      utcDate: null == utcDate
          ? _value.utcDate
          : utcDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      scoreHome: null == scoreHome
          ? _value.scoreHome
          : scoreHome // ignore: cast_nullable_to_non_nullable
              as int,
      scoreAway: null == scoreAway
          ? _value.scoreAway
          : scoreAway // ignore: cast_nullable_to_non_nullable
              as int,
      result: freezed == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as MatchResult?,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      oddsDraw: null == oddsDraw
          ? _value.oddsDraw
          : oddsDraw // ignore: cast_nullable_to_non_nullable
              as double,
      overUnderLine: null == overUnderLine
          ? _value.overUnderLine
          : overUnderLine // ignore: cast_nullable_to_non_nullable
              as double,
      isSimulated: null == isSimulated
          ? _value.isSimulated
          : isSimulated // ignore: cast_nullable_to_non_nullable
              as bool,
      leagueName: null == leagueName
          ? _value.leagueName
          : leagueName // ignore: cast_nullable_to_non_nullable
              as String,
      homeTeamLogo: null == homeTeamLogo
          ? _value.homeTeamLogo
          : homeTeamLogo // ignore: cast_nullable_to_non_nullable
              as String,
      awayTeamLogo: null == awayTeamLogo
          ? _value.awayTeamLogo
          : awayTeamLogo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchModelImpl implements _MatchModel {
  const _$MatchModelImpl(
      {required this.id,
      required this.homeTeam,
      required this.awayTeam,
      required this.utcDate,
      required this.status,
      this.scoreHome = 0,
      this.scoreAway = 0,
      this.result,
      required this.oddsOver,
      required this.oddsUnder,
      this.oddsDraw = 3.2,
      required this.overUnderLine,
      this.isSimulated = false,
      this.leagueName = '',
      this.homeTeamLogo = '',
      this.awayTeamLogo = ''});

  factory _$MatchModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchModelImplFromJson(json);

  @override
  final String id;
  @override
  final String homeTeam;
  @override
  final String awayTeam;
  @override
  final DateTime utcDate;
  @override
  final MatchStatus status;
  @override
  @JsonKey()
  final int scoreHome;
  @override
  @JsonKey()
  final int scoreAway;
  @override
  final MatchResult? result;
  @override
  final double oddsOver;
  @override
  final double oddsUnder;
  @override
  @JsonKey()
  final double oddsDraw;
  @override
  final double overUnderLine;
  @override
  @JsonKey()
  final bool isSimulated;
  @override
  @JsonKey()
  final String leagueName;
  @override
  @JsonKey()
  final String homeTeamLogo;
  @override
  @JsonKey()
  final String awayTeamLogo;

  @override
  String toString() {
    return 'MatchModel(id: $id, homeTeam: $homeTeam, awayTeam: $awayTeam, utcDate: $utcDate, status: $status, scoreHome: $scoreHome, scoreAway: $scoreAway, result: $result, oddsOver: $oddsOver, oddsUnder: $oddsUnder, oddsDraw: $oddsDraw, overUnderLine: $overUnderLine, isSimulated: $isSimulated, leagueName: $leagueName, homeTeamLogo: $homeTeamLogo, awayTeamLogo: $awayTeamLogo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.homeTeam, homeTeam) ||
                other.homeTeam == homeTeam) &&
            (identical(other.awayTeam, awayTeam) ||
                other.awayTeam == awayTeam) &&
            (identical(other.utcDate, utcDate) || other.utcDate == utcDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.scoreHome, scoreHome) ||
                other.scoreHome == scoreHome) &&
            (identical(other.scoreAway, scoreAway) ||
                other.scoreAway == scoreAway) &&
            (identical(other.result, result) || other.result == result) &&
            (identical(other.oddsOver, oddsOver) ||
                other.oddsOver == oddsOver) &&
            (identical(other.oddsUnder, oddsUnder) ||
                other.oddsUnder == oddsUnder) &&
            (identical(other.oddsDraw, oddsDraw) ||
                other.oddsDraw == oddsDraw) &&
            (identical(other.overUnderLine, overUnderLine) ||
                other.overUnderLine == overUnderLine) &&
            (identical(other.isSimulated, isSimulated) ||
                other.isSimulated == isSimulated) &&
            (identical(other.leagueName, leagueName) ||
                other.leagueName == leagueName) &&
            (identical(other.homeTeamLogo, homeTeamLogo) ||
                other.homeTeamLogo == homeTeamLogo) &&
            (identical(other.awayTeamLogo, awayTeamLogo) ||
                other.awayTeamLogo == awayTeamLogo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      homeTeam,
      awayTeam,
      utcDate,
      status,
      scoreHome,
      scoreAway,
      result,
      oddsOver,
      oddsUnder,
      oddsDraw,
      overUnderLine,
      isSimulated,
      leagueName,
      homeTeamLogo,
      awayTeamLogo);

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      __$$MatchModelImplCopyWithImpl<_$MatchModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchModelImplToJson(
      this,
    );
  }
}

abstract class _MatchModel implements MatchModel {
  const factory _MatchModel(
      {required final String id,
      required final String homeTeam,
      required final String awayTeam,
      required final DateTime utcDate,
      required final MatchStatus status,
      final int scoreHome,
      final int scoreAway,
      final MatchResult? result,
      required final double oddsOver,
      required final double oddsUnder,
      final double oddsDraw,
      required final double overUnderLine,
      final bool isSimulated,
      final String leagueName,
      final String homeTeamLogo,
      final String awayTeamLogo}) = _$MatchModelImpl;

  factory _MatchModel.fromJson(Map<String, dynamic> json) =
      _$MatchModelImpl.fromJson;

  @override
  String get id;
  @override
  String get homeTeam;
  @override
  String get awayTeam;
  @override
  DateTime get utcDate;
  @override
  MatchStatus get status;
  @override
  int get scoreHome;
  @override
  int get scoreAway;
  @override
  MatchResult? get result;
  @override
  double get oddsOver;
  @override
  double get oddsUnder;
  @override
  double get oddsDraw;
  @override
  double get overUnderLine;
  @override
  bool get isSimulated;
  @override
  String get leagueName;
  @override
  String get homeTeamLogo;
  @override
  String get awayTeamLogo;

  /// Create a copy of MatchModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchModelImplCopyWith<_$MatchModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
