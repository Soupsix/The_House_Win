// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'slot_machine_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SlotMachineState {
  SlotMachineConfigModel? get config => throw _privateConstructorUsedError;
  bool get isSpinning => throw _privateConstructorUsedError;
  SlotResultModel? get lastResult => throw _privateConstructorUsedError;
  List<SlotResultModel> get history => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SlotMachineStateCopyWith<SlotMachineState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SlotMachineStateCopyWith<$Res> {
  factory $SlotMachineStateCopyWith(
          SlotMachineState value, $Res Function(SlotMachineState) then) =
      _$SlotMachineStateCopyWithImpl<$Res, SlotMachineState>;
  @useResult
  $Res call(
      {SlotMachineConfigModel? config,
      bool isSpinning,
      SlotResultModel? lastResult,
      List<SlotResultModel> history,
      bool isLoading,
      String? errorMessage});

  $SlotMachineConfigModelCopyWith<$Res>? get config;
  $SlotResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class _$SlotMachineStateCopyWithImpl<$Res, $Val extends SlotMachineState>
    implements $SlotMachineStateCopyWith<$Res> {
  _$SlotMachineStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = freezed,
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
              as SlotMachineConfigModel?,
      isSpinning: null == isSpinning
          ? _value.isSpinning
          : isSpinning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SlotResultModel?,
      history: null == history
          ? _value.history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SlotResultModel>,
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

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotMachineConfigModelCopyWith<$Res>? get config {
    if (_value.config == null) {
      return null;
    }

    return $SlotMachineConfigModelCopyWith<$Res>(_value.config!, (value) {
      return _then(_value.copyWith(config: value) as $Val);
    });
  }

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $SlotResultModelCopyWith<$Res>? get lastResult {
    if (_value.lastResult == null) {
      return null;
    }

    return $SlotResultModelCopyWith<$Res>(_value.lastResult!, (value) {
      return _then(_value.copyWith(lastResult: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$SlotMachineStateImplCopyWith<$Res>
    implements $SlotMachineStateCopyWith<$Res> {
  factory _$$SlotMachineStateImplCopyWith(_$SlotMachineStateImpl value,
          $Res Function(_$SlotMachineStateImpl) then) =
      __$$SlotMachineStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {SlotMachineConfigModel? config,
      bool isSpinning,
      SlotResultModel? lastResult,
      List<SlotResultModel> history,
      bool isLoading,
      String? errorMessage});

  @override
  $SlotMachineConfigModelCopyWith<$Res>? get config;
  @override
  $SlotResultModelCopyWith<$Res>? get lastResult;
}

/// @nodoc
class __$$SlotMachineStateImplCopyWithImpl<$Res>
    extends _$SlotMachineStateCopyWithImpl<$Res, _$SlotMachineStateImpl>
    implements _$$SlotMachineStateImplCopyWith<$Res> {
  __$$SlotMachineStateImplCopyWithImpl(_$SlotMachineStateImpl _value,
      $Res Function(_$SlotMachineStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? config = freezed,
    Object? isSpinning = null,
    Object? lastResult = freezed,
    Object? history = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$SlotMachineStateImpl(
      config: freezed == config
          ? _value.config
          : config // ignore: cast_nullable_to_non_nullable
              as SlotMachineConfigModel?,
      isSpinning: null == isSpinning
          ? _value.isSpinning
          : isSpinning // ignore: cast_nullable_to_non_nullable
              as bool,
      lastResult: freezed == lastResult
          ? _value.lastResult
          : lastResult // ignore: cast_nullable_to_non_nullable
              as SlotResultModel?,
      history: null == history
          ? _value._history
          : history // ignore: cast_nullable_to_non_nullable
              as List<SlotResultModel>,
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

class _$SlotMachineStateImpl implements _SlotMachineState {
  const _$SlotMachineStateImpl(
      {this.config,
      this.isSpinning = false,
      this.lastResult,
      final List<SlotResultModel> history = const [],
      this.isLoading = false,
      this.errorMessage})
      : _history = history;

  @override
  final SlotMachineConfigModel? config;
  @override
  @JsonKey()
  final bool isSpinning;
  @override
  final SlotResultModel? lastResult;
  final List<SlotResultModel> _history;
  @override
  @JsonKey()
  List<SlotResultModel> get history {
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
    return 'SlotMachineState(config: $config, isSpinning: $isSpinning, lastResult: $lastResult, history: $history, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SlotMachineStateImpl &&
            (identical(other.config, config) || other.config == config) &&
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
  int get hashCode => Object.hash(runtimeType, config, isSpinning, lastResult,
      const DeepCollectionEquality().hash(_history), isLoading, errorMessage);

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SlotMachineStateImplCopyWith<_$SlotMachineStateImpl> get copyWith =>
      __$$SlotMachineStateImplCopyWithImpl<_$SlotMachineStateImpl>(
          this, _$identity);
}

abstract class _SlotMachineState implements SlotMachineState {
  const factory _SlotMachineState(
      {final SlotMachineConfigModel? config,
      final bool isSpinning,
      final SlotResultModel? lastResult,
      final List<SlotResultModel> history,
      final bool isLoading,
      final String? errorMessage}) = _$SlotMachineStateImpl;

  @override
  SlotMachineConfigModel? get config;
  @override
  bool get isSpinning;
  @override
  SlotResultModel? get lastResult;
  @override
  List<SlotResultModel> get history;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;

  /// Create a copy of SlotMachineState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SlotMachineStateImplCopyWith<_$SlotMachineStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
