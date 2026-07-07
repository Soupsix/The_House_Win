// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'anti_gambling_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$AntiGamblingState {
  bool get showLoanTrap =>
      throw _privateConstructorUsedError; // hiện nút vay vốn giả (bẫy nợ để cảnh báo)
  bool get showWarningOverlay =>
      throw _privateConstructorUsedError; // hiện màn hình đỏ cảnh báo khẩn cấp
  int get brokeCount =>
      throw _privateConstructorUsedError; // số lần người chơi cháy túi
  int get loanTrapClickCount =>
      throw _privateConstructorUsedError; // số lần người chơi click bẫy vay vốn
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of AntiGamblingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AntiGamblingStateCopyWith<AntiGamblingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AntiGamblingStateCopyWith<$Res> {
  factory $AntiGamblingStateCopyWith(
          AntiGamblingState value, $Res Function(AntiGamblingState) then) =
      _$AntiGamblingStateCopyWithImpl<$Res, AntiGamblingState>;
  @useResult
  $Res call(
      {bool showLoanTrap,
      bool showWarningOverlay,
      int brokeCount,
      int loanTrapClickCount,
      bool isLoading});
}

/// @nodoc
class _$AntiGamblingStateCopyWithImpl<$Res, $Val extends AntiGamblingState>
    implements $AntiGamblingStateCopyWith<$Res> {
  _$AntiGamblingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AntiGamblingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showLoanTrap = null,
    Object? showWarningOverlay = null,
    Object? brokeCount = null,
    Object? loanTrapClickCount = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      showLoanTrap: null == showLoanTrap
          ? _value.showLoanTrap
          : showLoanTrap // ignore: cast_nullable_to_non_nullable
              as bool,
      showWarningOverlay: null == showWarningOverlay
          ? _value.showWarningOverlay
          : showWarningOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      brokeCount: null == brokeCount
          ? _value.brokeCount
          : brokeCount // ignore: cast_nullable_to_non_nullable
              as int,
      loanTrapClickCount: null == loanTrapClickCount
          ? _value.loanTrapClickCount
          : loanTrapClickCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AntiGamblingStateImplCopyWith<$Res>
    implements $AntiGamblingStateCopyWith<$Res> {
  factory _$$AntiGamblingStateImplCopyWith(_$AntiGamblingStateImpl value,
          $Res Function(_$AntiGamblingStateImpl) then) =
      __$$AntiGamblingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool showLoanTrap,
      bool showWarningOverlay,
      int brokeCount,
      int loanTrapClickCount,
      bool isLoading});
}

/// @nodoc
class __$$AntiGamblingStateImplCopyWithImpl<$Res>
    extends _$AntiGamblingStateCopyWithImpl<$Res, _$AntiGamblingStateImpl>
    implements _$$AntiGamblingStateImplCopyWith<$Res> {
  __$$AntiGamblingStateImplCopyWithImpl(_$AntiGamblingStateImpl _value,
      $Res Function(_$AntiGamblingStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of AntiGamblingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? showLoanTrap = null,
    Object? showWarningOverlay = null,
    Object? brokeCount = null,
    Object? loanTrapClickCount = null,
    Object? isLoading = null,
  }) {
    return _then(_$AntiGamblingStateImpl(
      showLoanTrap: null == showLoanTrap
          ? _value.showLoanTrap
          : showLoanTrap // ignore: cast_nullable_to_non_nullable
              as bool,
      showWarningOverlay: null == showWarningOverlay
          ? _value.showWarningOverlay
          : showWarningOverlay // ignore: cast_nullable_to_non_nullable
              as bool,
      brokeCount: null == brokeCount
          ? _value.brokeCount
          : brokeCount // ignore: cast_nullable_to_non_nullable
              as int,
      loanTrapClickCount: null == loanTrapClickCount
          ? _value.loanTrapClickCount
          : loanTrapClickCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$AntiGamblingStateImpl implements _AntiGamblingState {
  const _$AntiGamblingStateImpl(
      {this.showLoanTrap = false,
      this.showWarningOverlay = false,
      this.brokeCount = 0,
      this.loanTrapClickCount = 0,
      this.isLoading = false});

  @override
  @JsonKey()
  final bool showLoanTrap;
// hiện nút vay vốn giả (bẫy nợ để cảnh báo)
  @override
  @JsonKey()
  final bool showWarningOverlay;
// hiện màn hình đỏ cảnh báo khẩn cấp
  @override
  @JsonKey()
  final int brokeCount;
// số lần người chơi cháy túi
  @override
  @JsonKey()
  final int loanTrapClickCount;
// số lần người chơi click bẫy vay vốn
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'AntiGamblingState(showLoanTrap: $showLoanTrap, showWarningOverlay: $showWarningOverlay, brokeCount: $brokeCount, loanTrapClickCount: $loanTrapClickCount, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AntiGamblingStateImpl &&
            (identical(other.showLoanTrap, showLoanTrap) ||
                other.showLoanTrap == showLoanTrap) &&
            (identical(other.showWarningOverlay, showWarningOverlay) ||
                other.showWarningOverlay == showWarningOverlay) &&
            (identical(other.brokeCount, brokeCount) ||
                other.brokeCount == brokeCount) &&
            (identical(other.loanTrapClickCount, loanTrapClickCount) ||
                other.loanTrapClickCount == loanTrapClickCount) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(runtimeType, showLoanTrap, showWarningOverlay,
      brokeCount, loanTrapClickCount, isLoading);

  /// Create a copy of AntiGamblingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AntiGamblingStateImplCopyWith<_$AntiGamblingStateImpl> get copyWith =>
      __$$AntiGamblingStateImplCopyWithImpl<_$AntiGamblingStateImpl>(
          this, _$identity);
}

abstract class _AntiGamblingState implements AntiGamblingState {
  const factory _AntiGamblingState(
      {final bool showLoanTrap,
      final bool showWarningOverlay,
      final int brokeCount,
      final int loanTrapClickCount,
      final bool isLoading}) = _$AntiGamblingStateImpl;

  @override
  bool get showLoanTrap; // hiện nút vay vốn giả (bẫy nợ để cảnh báo)
  @override
  bool get showWarningOverlay; // hiện màn hình đỏ cảnh báo khẩn cấp
  @override
  int get brokeCount; // số lần người chơi cháy túi
  @override
  int get loanTrapClickCount; // số lần người chơi click bẫy vay vốn
  @override
  bool get isLoading;

  /// Create a copy of AntiGamblingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AntiGamblingStateImplCopyWith<_$AntiGamblingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
