// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SimulationResultModel _$SimulationResultModelFromJson(
    Map<String, dynamic> json) {
  return _SimulationResultModel.fromJson(json);
}

/// @nodoc
mixin _$SimulationResultModel {
  double get avgFinalBalance => throw _privateConstructorUsedError;
  int get bustCount => throw _privateConstructorUsedError; // số đường cháy túi
  int get profitCount => throw _privateConstructorUsedError; // số đường còn lãi
  double get houseEdge => throw _privateConstructorUsedError;
  double get expectedValue => throw _privateConstructorUsedError;
  DateTime get runAt => throw _privateConstructorUsedError;

  /// Serializes this SimulationResultModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SimulationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimulationResultModelCopyWith<SimulationResultModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationResultModelCopyWith<$Res> {
  factory $SimulationResultModelCopyWith(SimulationResultModel value,
          $Res Function(SimulationResultModel) then) =
      _$SimulationResultModelCopyWithImpl<$Res, SimulationResultModel>;
  @useResult
  $Res call(
      {double avgFinalBalance,
      int bustCount,
      int profitCount,
      double houseEdge,
      double expectedValue,
      DateTime runAt});
}

/// @nodoc
class _$SimulationResultModelCopyWithImpl<$Res,
        $Val extends SimulationResultModel>
    implements $SimulationResultModelCopyWith<$Res> {
  _$SimulationResultModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimulationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgFinalBalance = null,
    Object? bustCount = null,
    Object? profitCount = null,
    Object? houseEdge = null,
    Object? expectedValue = null,
    Object? runAt = null,
  }) {
    return _then(_value.copyWith(
      avgFinalBalance: null == avgFinalBalance
          ? _value.avgFinalBalance
          : avgFinalBalance // ignore: cast_nullable_to_non_nullable
              as double,
      bustCount: null == bustCount
          ? _value.bustCount
          : bustCount // ignore: cast_nullable_to_non_nullable
              as int,
      profitCount: null == profitCount
          ? _value.profitCount
          : profitCount // ignore: cast_nullable_to_non_nullable
              as int,
      houseEdge: null == houseEdge
          ? _value.houseEdge
          : houseEdge // ignore: cast_nullable_to_non_nullable
              as double,
      expectedValue: null == expectedValue
          ? _value.expectedValue
          : expectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      runAt: null == runAt
          ? _value.runAt
          : runAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SimulationResultModelImplCopyWith<$Res>
    implements $SimulationResultModelCopyWith<$Res> {
  factory _$$SimulationResultModelImplCopyWith(
          _$SimulationResultModelImpl value,
          $Res Function(_$SimulationResultModelImpl) then) =
      __$$SimulationResultModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double avgFinalBalance,
      int bustCount,
      int profitCount,
      double houseEdge,
      double expectedValue,
      DateTime runAt});
}

/// @nodoc
class __$$SimulationResultModelImplCopyWithImpl<$Res>
    extends _$SimulationResultModelCopyWithImpl<$Res,
        _$SimulationResultModelImpl>
    implements _$$SimulationResultModelImplCopyWith<$Res> {
  __$$SimulationResultModelImplCopyWithImpl(_$SimulationResultModelImpl _value,
      $Res Function(_$SimulationResultModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimulationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? avgFinalBalance = null,
    Object? bustCount = null,
    Object? profitCount = null,
    Object? houseEdge = null,
    Object? expectedValue = null,
    Object? runAt = null,
  }) {
    return _then(_$SimulationResultModelImpl(
      avgFinalBalance: null == avgFinalBalance
          ? _value.avgFinalBalance
          : avgFinalBalance // ignore: cast_nullable_to_non_nullable
              as double,
      bustCount: null == bustCount
          ? _value.bustCount
          : bustCount // ignore: cast_nullable_to_non_nullable
              as int,
      profitCount: null == profitCount
          ? _value.profitCount
          : profitCount // ignore: cast_nullable_to_non_nullable
              as int,
      houseEdge: null == houseEdge
          ? _value.houseEdge
          : houseEdge // ignore: cast_nullable_to_non_nullable
              as double,
      expectedValue: null == expectedValue
          ? _value.expectedValue
          : expectedValue // ignore: cast_nullable_to_non_nullable
              as double,
      runAt: null == runAt
          ? _value.runAt
          : runAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SimulationResultModelImpl implements _SimulationResultModel {
  const _$SimulationResultModelImpl(
      {required this.avgFinalBalance,
      required this.bustCount,
      required this.profitCount,
      required this.houseEdge,
      required this.expectedValue,
      required this.runAt});

  factory _$SimulationResultModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SimulationResultModelImplFromJson(json);

  @override
  final double avgFinalBalance;
  @override
  final int bustCount;
// số đường cháy túi
  @override
  final int profitCount;
// số đường còn lãi
  @override
  final double houseEdge;
  @override
  final double expectedValue;
  @override
  final DateTime runAt;

  @override
  String toString() {
    return 'SimulationResultModel(avgFinalBalance: $avgFinalBalance, bustCount: $bustCount, profitCount: $profitCount, houseEdge: $houseEdge, expectedValue: $expectedValue, runAt: $runAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationResultModelImpl &&
            (identical(other.avgFinalBalance, avgFinalBalance) ||
                other.avgFinalBalance == avgFinalBalance) &&
            (identical(other.bustCount, bustCount) ||
                other.bustCount == bustCount) &&
            (identical(other.profitCount, profitCount) ||
                other.profitCount == profitCount) &&
            (identical(other.houseEdge, houseEdge) ||
                other.houseEdge == houseEdge) &&
            (identical(other.expectedValue, expectedValue) ||
                other.expectedValue == expectedValue) &&
            (identical(other.runAt, runAt) || other.runAt == runAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, avgFinalBalance, bustCount,
      profitCount, houseEdge, expectedValue, runAt);

  /// Create a copy of SimulationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationResultModelImplCopyWith<_$SimulationResultModelImpl>
      get copyWith => __$$SimulationResultModelImplCopyWithImpl<
          _$SimulationResultModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SimulationResultModelImplToJson(
      this,
    );
  }
}

abstract class _SimulationResultModel implements SimulationResultModel {
  const factory _SimulationResultModel(
      {required final double avgFinalBalance,
      required final int bustCount,
      required final int profitCount,
      required final double houseEdge,
      required final double expectedValue,
      required final DateTime runAt}) = _$SimulationResultModelImpl;

  factory _SimulationResultModel.fromJson(Map<String, dynamic> json) =
      _$SimulationResultModelImpl.fromJson;

  @override
  double get avgFinalBalance;
  @override
  int get bustCount; // số đường cháy túi
  @override
  int get profitCount; // số đường còn lãi
  @override
  double get houseEdge;
  @override
  double get expectedValue;
  @override
  DateTime get runAt;

  /// Create a copy of SimulationResultModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationResultModelImplCopyWith<_$SimulationResultModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
