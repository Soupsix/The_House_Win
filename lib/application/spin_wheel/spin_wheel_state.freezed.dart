// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spin_wheel_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SpinWheelState {
  SpinWheelConfigModel? get config => throw _privateConstructorUsedError;
  double get betAmount => throw _privateConstructorUsedError;
  bool get isSpinning => throw _privateConstructorUsedError;
  SpinResultModel? get lastResult => throw _privateConstructorUsedError;
  List<SpinResultModel> get history => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpinWheelStateCopyWith<SpinWheelState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpinWheelStateCopyWith<$Res> {
  factory $SpinWheelStateCopyWith(
          SpinWheelState value, $Res Function(SpinWheelState) then) =
      _$SpinWheelStateCopyWithImpl<$Res, SpinWheelState>;
  @useResult
  $Res call(
      {SpinWheelConfigModel? config,
      double betAmount,
      bool isSpinning,
      SpinResultModel? lastResult,
      List<SpinResultModel> history,
      bool isLoading,
      String? errorMessage});

  $SpinWheelConfigModelCopyWith<$Res>? get config;
  $SpinResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class _$SpinWheelStateCopyWithImpl<$Res, $Val extends SpinWheelState>
    implements $SpinWheelStateCopyWith<$Res> {
  _$SpinWheelStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = freezed,
    Object? betAmount = null,
    Object? isSpinning = null,
    Object? lastResult = freezed,
    Object? history = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpinWheelConfigModel?,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isSpinning: null == isSpinning
          ? _value.isSpinning
          : isSpinning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SpinResultModel?,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SpinResultModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpinWheelConfigModelCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $SpinWheelConfigModelCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SpinResultModelCopyWith<$Res>? get lastResult {
    if (_value.lastResult == null) {
      return null;
    }

    return $SpinResultModelCopyWith<$Res>(_value.lastResult!, (value) {
      return _then(_value.copyWith(lastResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SpinWheelStateImplCopyWith<$Res>
    implements $SpinWheelStateCopyWith<$Res> {
  factory _$$SpinWheelStateImplCopyWith(_$SpinWheelStateImpl value,
          $Res Function(_$SpinWheelStateImpl) then) =
      __$$SpinWheelStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SpinWheelConfigModel? config,
      double betAmount,
      bool isSpinning,
      SpinResultModel? lastResult,
      List<SpinResultModel> history,
      bool isLoading,
      String? errorMessage});

  @override
  $SpinWheelConfigModelCopyWith<$Res>? get config;
  @override
  $SpinResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class __$$SpinWheelStateImplCopyWithImpl<$Res>
    extends _$SpinWheelStateCopyWithImpl<$Res, _$SpinWheelStateImpl>
    implements _$$SpinWheelStateImplCopyWith<$Res> {
  __$$SpinWheelStateImplCopyWithImpl(
      _$SpinWheelStateImpl _value, $Res Function(_$SpinWheelStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = freezed,
    Object? betAmount = null,
    Object? isSpinning = null,
    Object? lastResult = freezed,
    Object? history = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$SpinWheelStateImpl(
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SpinWheelConfigModel?,
      betAmount: null == betAmount
          ? _value.betAmount
          : betAmount // ignore: cast_nullable_to_non_nullable
              as double,
      isSpinning: null == isSpinning
          ? _value.isSpinning
          : isSpinning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SpinResultModel?,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SpinResultModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$SpinWheelStateImpl implements _SpinWheelState {
  const _$SpinWheelStateImpl(
      {this.config,
      this.betAmount = 10000.0,
      this.isSpinning = false,
      this.lastResult,
      final List<SpinResultModel> history = const [],
      this.isLoading = false,
      this.errorMessage})
      : _history = history;

  @override
  final SpinWheelConfigModel? config;
  @override
  @JsonKey()
  final double betAmount;
  @override
  @JsonKey()
  final bool isSpinning;
  @override
  final SpinResultModel? lastResult;
  final List<SpinResultModel> _history;
  @override
  @JsonKey()
  List<SpinResultModel> get history {
    if (_history is EqualUnmodifiableListView) return _history;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_history);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SpinWheelState(config: $config, betAmount: $betAmount, isSpinning: $isSpinning, lastResult: $lastResult, history: $history, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpinWheelStateImpl &&
            (identical(other.config, config) || other.config == config) &&
            (identical(other.betAmount, betAmount) ||
                other.betAmount == betAmount) &&
            (identical(other.isSpinning, isSpinning) ||
                other.isSpinning == isSpinning) &&
            (identical(other.lastResult, lastResult) ||
                other.lastResult == lastResult) &&
            const DeepCollectionEquality().equals(other._history, _history) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      config,
      betAmount,
      isSpinning,
      lastResult,
      const DeepCollectionEquality().hash(_history),
      isLoading,
      errorMessage);

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpinWheelStateImplCopyWith<_$SpinWheelStateImpl> get copyWith =>
      __$$SpinWheelStateImplCopyWithImpl<_$SpinWheelStateImpl>(
          this, _$identity);
}

abstract class _SpinWheelState implements SpinWheelState {
  const factory _SpinWheelState(
      {final SpinWheelConfigModel? config,
      final double betAmount,
      final bool isSpinning,
      final SpinResultModel? lastResult,
      final List<SpinResultModel> history,
      final bool isLoading,
      final String? errorMessage}) = _$SpinWheelStateImpl;

  @override
  SpinWheelConfigModel? get config;
  @override
  double get betAmount;
  @override
  bool get isSpinning;
  @override
  SpinResultModel? get lastResult;
  @override
  List<SpinResultModel> get history;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of SpinWheelState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpinWheelStateImplCopyWith<_$SpinWheelStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
