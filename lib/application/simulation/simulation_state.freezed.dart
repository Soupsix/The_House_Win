// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'simulation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SimulationState {
  int get numBets =>
      throw _privateConstructorUsedError; // số trận đặt cược trong một chuỗi mô phỏng
  double get betAmount =>
      throw _privateConstructorUsedError; // số tiền cược cố định mỗi trận
  int get numPaths =>
      throw _privateConstructorUsedError; // số đường chạy mô phỏng song song (tối đa 5 đường để vẽ biểu đồ)
  double get oddsOver =>
      throw _privateConstructorUsedError; // tỷ lệ ăn cược cửa Tài
  double get oddsUnder =>
      throw _privateConstructorUsedError; // tỷ lệ ăn cược cửa Xỉu
  List<List<double>> get simulationPaths =>
      throw _privateConstructorUsedError; // lịch sử số dư cho từng đường chạy
  bool get isRunning =>
      throw _privateConstructorUsedError; // trạng thái đang tính toán mô phỏng
  SimulationResultModel? get lastResult => throw _privateConstructorUsedError;

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SimulationStateCopyWith<SimulationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SimulationStateCopyWith<$Res> {
  factory $SimulationStateCopyWith(
          SimulationState value, $Res Function(SimulationState) then) =
      _$SimulationStateCopyWithImpl<$Res, SimulationState>;
  @useResult
  $Res call(
      {int numBets,
      double betAmount,
      int numPaths,
      double oddsOver,
      double oddsUnder,
      List<List<double>> simulationPaths,
      bool isRunning,
      SimulationResultModel? lastResult});

  $SimulationResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class _$SimulationStateCopyWithImpl<$Res, $Val extends SimulationState>
    implements $SimulationStateCopyWith<$Res> {
  _$SimulationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numBets = null,
    Object? betAmount = null,
    Object? numPaths = null,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? simulationPaths = null,
    Object? isRunning = null,
    Object? lastResult = freezed,
  }) {
    return _then(_value.copyWith(
      numBets: null == numBets
          ? _value.numBets
          : numBets // ignore: cast_nullable_to_non_nullable
              as int,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      numPaths: null == numPaths
          ? _value.numPaths
          : numPaths // ignore: cast_nullable_to_non_nullable
              as int,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      simulationPaths: null == simulationPaths
          ? _value.simulationPaths
          : simulationPaths // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SimulationResultModel?,
    ) as $Val);
  }

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SimulationResultModelCopyWith<$Res>? get lastResult {
    if (_value.lastResult == null) {
      return null;
    }

    return $SimulationResultModelCopyWith<$Res>(_value.lastResult!, (value) {
      return _then(_value.copyWith(lastResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SimulationStateImplCopyWith<$Res>
    implements $SimulationStateCopyWith<$Res> {
  factory _$$SimulationStateImplCopyWith(_$SimulationStateImpl value,
          $Res Function(_$SimulationStateImpl) then) =
      __$$SimulationStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int numBets,
      double betAmount,
      int numPaths,
      double oddsOver,
      double oddsUnder,
      List<List<double>> simulationPaths,
      bool isRunning,
      SimulationResultModel? lastResult});

  @override
  $SimulationResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class __$$SimulationStateImplCopyWithImpl<$Res>
    extends _$SimulationStateCopyWithImpl<$Res, _$SimulationStateImpl>
    implements _$$SimulationStateImplCopyWith<$Res> {
  __$$SimulationStateImplCopyWithImpl(
      _$SimulationStateImpl _value, $Res Function(_$SimulationStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? numBets = null,
    Object? betAmount = null,
    Object? numPaths = null,
    Object? oddsOver = null,
    Object? oddsUnder = null,
    Object? simulationPaths = null,
    Object? isRunning = null,
    Object? lastResult = freezed,
  }) {
    return _then(_$SimulationStateImpl(
      numBets: null == numBets
          ? _value.numBets
          : numBets // ignore: cast_nullable_to_non_nullable
              as int,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      numPaths: null == numPaths
          ? _value.numPaths
          : numPaths // ignore: cast_nullable_to_non_nullable
              as int,
      oddsOver: null == oddsOver
          ? _value.oddsOver
          : oddsOver // ignore: cast_nullable_to_non_nullable
              as double,
      oddsUnder: null == oddsUnder
          ? _value.oddsUnder
          : oddsUnder // ignore: cast_nullable_to_non_nullable
              as double,
      simulationPaths: null == simulationPaths
          ? _value._simulationPaths
          : simulationPaths // ignore: cast_nullable_to_non_nullable
              as List<List<double>>,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SimulationResultModel?,
    ));
  }
}

/// @nodoc

class _$SimulationStateImpl implements _SimulationState {
  const _$SimulationStateImpl(
      {this.numBets = 100,
      this.betAmount = 50000,
      this.numPaths = 5,
      this.oddsOver = 1.85,
      this.oddsUnder = 1.95,
      final List<List<double>> simulationPaths = const [],
      this.isRunning = false,
      this.lastResult})
      : _simulationPaths = simulationPaths;

  @override
  @JsonKey()
  final int numBets;
// số trận đặt cược trong một chuỗi mô phỏng
  @override
  @JsonKey()
  final double betAmount;
// số tiền cược cố định mỗi trận
  @override
  @JsonKey()
  final int numPaths;
// số đường chạy mô phỏng song song (tối đa 5 đường để vẽ biểu đồ)
  @override
  @JsonKey()
  final double oddsOver;
// tỷ lệ ăn cược cửa Tài
  @override
  @JsonKey()
  final double oddsUnder;
// tỷ lệ ăn cược cửa Xỉu
  final List<List<double>> _simulationPaths;
// tỷ lệ ăn cược cửa Xỉu
  @override
  @JsonKey()
  List<List<double>> get simulationPaths {
    if (_simulationPaths is EqualUnmodifiableListView) return _simulationPaths;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_simulationPaths);
  }

// lịch sử số dư cho từng đường chạy
  @override
  @JsonKey()
  final bool isRunning;
// trạng thái đang tính toán mô phỏng
  @override
  final SimulationResultModel? lastResult;

  @override
  String toString() {
    return 'SimulationState(numBets: $numBets, betAmount: $betAmount, numPaths: $numPaths, oddsOver: $oddsOver, oddsUnder: $oddsUnder, simulationPaths: $simulationPaths, isRunning: $isRunning, lastResult: $lastResult)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SimulationStateImpl &&
            (identical(other.numBets, numBets) || other.numBets == numBets) &&
            (identical(other.betAmount, betAmount) ||
                other.betAmount == betAmount) &&
            (identical(other.numPaths, numPaths) ||
                other.numPaths == numPaths) &&
            (identical(other.oddsOver, oddsOver) ||
                other.oddsOver == oddsOver) &&
            (identical(other.oddsUnder, oddsUnder) ||
                other.oddsUnder == oddsUnder) &&
            const DeepCollectionEquality()
                .equals(other._simulationPaths, _simulationPaths) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      numBets,
      betAmount,
      numPaths,
      oddsOver,
      oddsUnder,
      const DeepCollectionEquality().hash(_simulationPaths),
      isRunning,
      lastResult);

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SimulationStateImplCopyWith<_$SimulationStateImpl> get copyWith =>
      __$$SimulationStateImplCopyWithImpl<_$SimulationStateImpl>(
          this, _$identity);
}

abstract class _SimulationState implements SimulationState {
  const factory _SimulationState(
      {final int numBets,
      final double betAmount,
      final int numPaths,
      final double oddsOver,
      final double oddsUnder,
      final List<List<double>> simulationPaths,
      final bool isRunning,
      final SimulationResultModel? lastResult}) = _$SimulationStateImpl;

  @override
  int get numBets; // số trận đặt cược trong một chuỗi mô phỏng
  @override
  double get betAmount; // số tiền cược cố định mỗi trận
  @override
  int get numPaths; // số đường chạy mô phỏng song song (tối đa 5 đường để vẽ biểu đồ)
  @override
  double get oddsOver; // tỷ lệ ăn cược cửa Tài
  @override
  double get oddsUnder; // tỷ lệ ăn cược cửa Xỉu
  @override
  List<List<double>> get simulationPaths; // lịch sử số dư cho từng đường chạy
  @override
  bool get isRunning; // trạng thái đang tính toán mô phỏng
  @override
  SimulationResultModel? get lastResult;

  /// Create a copy of SimulationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SimulationStateImplCopyWith<_$SimulationStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
