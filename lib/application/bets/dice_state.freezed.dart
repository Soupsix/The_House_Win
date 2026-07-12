// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dice_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DiceState {
// Phiên cược Tài Xỉu đang active
  BettingSessionModel? get activeSession =>
      throw _privateConstructorUsedError; // Countdown còn lại của phiên (60 → 0)
  int get countdown =>
      throw _privateConstructorUsedError; // Trạng thái phiên hiện tại
  SessionStatus get sessionStatus =>
      throw _privateConstructorUsedError; // Đơn cược nháp đang nhập (chưa confirm)
  BetDraftModel? get currentDraft =>
      throw _privateConstructorUsedError; // Danh sách cược của user trong phiên hiện tại
  List<BetModel> get currentSessionBets =>
      throw _privateConstructorUsedError; // Lịch sử cược đã kết thúc
  List<BetModel> get settledBets => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiceStateCopyWith<DiceState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiceStateCopyWith<$Res> {
  factory $DiceStateCopyWith(DiceState value, $Res Function(DiceState) then) =
      _$DiceStateCopyWithImpl<$Res, DiceState>;
  @useResult
  $Res call(
      {BettingSessionModel? activeSession,
      int countdown,
      SessionStatus sessionStatus,
      BetDraftModel? currentDraft,
      List<BetModel> currentSessionBets,
      List<BetModel> settledBets,
      bool isSubmitting,
      bool isLoading,
      String? errorMessage,
      String? successMessage});

  $BettingSessionModelCopyWith<$Res>? get activeSession;
  $BetDraftModelCopyWith<$Res>? get currentDraft;
}

/// @nodoc
class _$DiceStateCopyWithImpl<$Res, $Val extends DiceState>
    implements $DiceStateCopyWith<$Res> {
  _$DiceStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeSession = freezed,
    Object? countdown = null,
    Object? sessionStatus = null,
    Object? currentDraft = freezed,
    Object? currentSessionBets = null,
    Object? settledBets = null,
    Object? isSubmitting = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_value.copyWith(
      activeSession: freezed == activeSession
          ? _value.activeSession
          : activeSession // ignore: cast_nullable_to_non_nullable
              as BettingSessionModel?,
      countdown: null == countdown
          ? _value.countdown
          : countdown // ignore: cast_nullable_to_non_nullable
              as int,
      sessionStatus: null == sessionStatus
          ? _value.sessionStatus
          : sessionStatus // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      currentDraft: freezed == currentDraft
          ? _value.currentDraft
          : currentDraft // ignore: cast_nullable_to_non_nullable
              as BetDraftModel?,
      currentSessionBets: null == currentSessionBets
          ? _value.currentSessionBets
          : currentSessionBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      settledBets: null == settledBets
          ? _value.settledBets
          : settledBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BettingSessionModelCopyWith<$Res>? get activeSession {
    if (_value.activeSession == null) {
      return null;
    }

    return $BettingSessionModelCopyWith<$Res>(_value.activeSession!, (value) {
      return _then(_value.copyWith(activeSession: value) as $Val);
    });
  }

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BetDraftModelCopyWith<$Res>? get currentDraft {
    if (_value.currentDraft == null) {
      return null;
    }

    return $BetDraftModelCopyWith<$Res>(_value.currentDraft!, (value) {
      return _then(_value.copyWith(currentDraft: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DiceStateImplCopyWith<$Res>
    implements $DiceStateCopyWith<$Res> {
  factory _$$DiceStateImplCopyWith(
          _$DiceStateImpl value, $Res Function(_$DiceStateImpl) then) =
      __$$DiceStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BettingSessionModel? activeSession,
      int countdown,
      SessionStatus sessionStatus,
      BetDraftModel? currentDraft,
      List<BetModel> currentSessionBets,
      List<BetModel> settledBets,
      bool isSubmitting,
      bool isLoading,
      String? errorMessage,
      String? successMessage});

  @override
  $BettingSessionModelCopyWith<$Res>? get activeSession;
  @override
  $BetDraftModelCopyWith<$Res>? get currentDraft;
}

/// @nodoc
class __$$DiceStateImplCopyWithImpl<$Res>
    extends _$DiceStateCopyWithImpl<$Res, _$DiceStateImpl>
    implements _$$DiceStateImplCopyWith<$Res> {
  __$$DiceStateImplCopyWithImpl(
      _$DiceStateImpl _value, $Res Function(_$DiceStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeSession = freezed,
    Object? countdown = null,
    Object? sessionStatus = null,
    Object? currentDraft = freezed,
    Object? currentSessionBets = null,
    Object? settledBets = null,
    Object? isSubmitting = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_$DiceStateImpl(
      activeSession: freezed == activeSession
          ? _value.activeSession
          : activeSession // ignore: cast_nullable_to_non_nullable
              as BettingSessionModel?,
      countdown: null == countdown
          ? _value.countdown
          : countdown // ignore: cast_nullable_to_non_nullable
              as int,
      sessionStatus: null == sessionStatus
          ? _value.sessionStatus
          : sessionStatus // ignore: cast_nullable_to_non_nullable
              as SessionStatus,
      currentDraft: freezed == currentDraft
          ? _value.currentDraft
          : currentDraft // ignore: cast_nullable_to_non_nullable
              as BetDraftModel?,
      currentSessionBets: null == currentSessionBets
          ? _value._currentSessionBets
          : currentSessionBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      settledBets: null == settledBets
          ? _value._settledBets
          : settledBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      isSubmitting: null == isSubmitting
          ? _value.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      successMessage: freezed == successMessage
          ? _value.successMessage
          : successMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$DiceStateImpl implements _DiceState {
  const _$DiceStateImpl(
      {this.activeSession,
      this.countdown = 60,
      this.sessionStatus = SessionStatus.open,
      this.currentDraft,
      final List<BetModel> currentSessionBets = const [],
      final List<BetModel> settledBets = const [],
      this.isSubmitting = false,
      this.isLoading = false,
      this.errorMessage,
      this.successMessage})
      : _currentSessionBets = currentSessionBets,
        _settledBets = settledBets;

// Phiên cược Tài Xỉu đang active
  @override
  final BettingSessionModel? activeSession;
// Countdown còn lại của phiên (60 → 0)
  @override
  @JsonKey()
  final int countdown;
// Trạng thái phiên hiện tại
  @override
  @JsonKey()
  final SessionStatus sessionStatus;
// Đơn cược nháp đang nhập (chưa confirm)
  @override
  final BetDraftModel? currentDraft;
// Danh sách cược của user trong phiên hiện tại
  final List<BetModel> _currentSessionBets;
// Danh sách cược của user trong phiên hiện tại
  @override
  @JsonKey()
  List<BetModel> get currentSessionBets {
    if (_currentSessionBets is EqualUnmodifiableListView)
      return _currentSessionBets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_currentSessionBets);
  }

// Lịch sử cược đã kết thúc
  final List<BetModel> _settledBets;
// Lịch sử cược đã kết thúc
  @override
  @JsonKey()
  List<BetModel> get settledBets {
    if (_settledBets is EqualUnmodifiableListView) return _settledBets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_settledBets);
  }

  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;
  @override
  final String? successMessage;

  @override
  String toString() {
    return 'DiceState(activeSession: $activeSession, countdown: $countdown, sessionStatus: $sessionStatus, currentDraft: $currentDraft, currentSessionBets: $currentSessionBets, settledBets: $settledBets, isSubmitting: $isSubmitting, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiceStateImpl &&
            (identical(other.activeSession, activeSession) ||
                other.activeSession == activeSession) &&
            (identical(other.countdown, countdown) ||
                other.countdown == countdown) &&
            (identical(other.sessionStatus, sessionStatus) ||
                other.sessionStatus == sessionStatus) &&
            (identical(other.currentDraft, currentDraft) ||
                other.currentDraft == currentDraft) &&
            const DeepCollectionEquality()
                .equals(other._currentSessionBets, _currentSessionBets) &&
            const DeepCollectionEquality()
                .equals(other._settledBets, _settledBets) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.successMessage, successMessage) ||
                other.successMessage == successMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      activeSession,
      countdown,
      sessionStatus,
      currentDraft,
      const DeepCollectionEquality().hash(_currentSessionBets),
      const DeepCollectionEquality().hash(_settledBets),
      isSubmitting,
      isLoading,
      errorMessage,
      successMessage);

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiceStateImplCopyWith<_$DiceStateImpl> get copyWith =>
      __$$DiceStateImplCopyWithImpl<_$DiceStateImpl>(this, _$identity);
}

abstract class _DiceState implements DiceState {
  const factory _DiceState(
      {final BettingSessionModel? activeSession,
      final int countdown,
      final SessionStatus sessionStatus,
      final BetDraftModel? currentDraft,
      final List<BetModel> currentSessionBets,
      final List<BetModel> settledBets,
      final bool isSubmitting,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage}) = _$DiceStateImpl;

// Phiên cược Tài Xỉu đang active
  @override
  BettingSessionModel?
      get activeSession; // Countdown còn lại của phiên (60 → 0)
  @override
  int get countdown; // Trạng thái phiên hiện tại
  @override
  SessionStatus get sessionStatus; // Đơn cược nháp đang nhập (chưa confirm)
  @override
  BetDraftModel?
      get currentDraft; // Danh sách cược của user trong phiên hiện tại
  @override
  List<BetModel> get currentSessionBets; // Lịch sử cược đã kết thúc
  @override
  List<BetModel> get settledBets;
  @override
  bool get isSubmitting;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  String? get successMessage;

  /// Create a copy of DiceState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiceStateImplCopyWith<_$DiceStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
