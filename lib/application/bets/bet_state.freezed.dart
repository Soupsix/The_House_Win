// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bet_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BetState {
// Đơn cược nháp đang nhập (chưa confirm)
  BetDraftModel? get currentDraft =>
      throw _privateConstructorUsedError; // Lịch sử cược đã kết thúc
  List<BetModel> get settledBets =>
      throw _privateConstructorUsedError; // Danh sách cược đang pending của bóng đá (giữ lại để tương thích)
  List<BetModel> get pendingBets => throw _privateConstructorUsedError;
  bool get isSubmitting => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;
  String? get successMessage => throw _privateConstructorUsedError;

  /// Create a copy of BetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BetStateCopyWith<BetState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BetStateCopyWith<$Res> {
  factory $BetStateCopyWith(BetState value, $Res Function(BetState) then) =
      _$BetStateCopyWithImpl<$Res, BetState>;
  @useResult
  $Res call(
      {BetDraftModel? currentDraft,
      List<BetModel> settledBets,
      List<BetModel> pendingBets,
      bool isSubmitting,
      bool isLoading,
      String? errorMessage,
      String? successMessage});

  $BetDraftModelCopyWith<$Res>? get currentDraft;
}

/// @nodoc
class _$BetStateCopyWithImpl<$Res, $Val extends BetState>
    implements $BetStateCopyWith<$Res> {
  _$BetStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentDraft = freezed,
    Object? settledBets = null,
    Object? pendingBets = null,
    Object? isSubmitting = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_value.copyWith(
      currentDraft: freezed == currentDraft
          ? _value.currentDraft
          : currentDraft // ignore: cast_nullable_to_non_nullable
              as BetDraftModel?,
      settledBets: null == settledBets
          ? _value.settledBets
          : settledBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      pendingBets: null == pendingBets
          ? _value.pendingBets
          : pendingBets // ignore: cast_nullable_to_non_nullable
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

  /// Create a copy of BetState
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
abstract class _$$BetStateImplCopyWith<$Res>
    implements $BetStateCopyWith<$Res> {
  factory _$$BetStateImplCopyWith(
          _$BetStateImpl value, $Res Function(_$BetStateImpl) then) =
      __$$BetStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {BetDraftModel? currentDraft,
      List<BetModel> settledBets,
      List<BetModel> pendingBets,
      bool isSubmitting,
      bool isLoading,
      String? errorMessage,
      String? successMessage});

  @override
  $BetDraftModelCopyWith<$Res>? get currentDraft;
}

/// @nodoc
class __$$BetStateImplCopyWithImpl<$Res>
    extends _$BetStateCopyWithImpl<$Res, _$BetStateImpl>
    implements _$$BetStateImplCopyWith<$Res> {
  __$$BetStateImplCopyWithImpl(
      _$BetStateImpl _value, $Res Function(_$BetStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of BetState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentDraft = freezed,
    Object? settledBets = null,
    Object? pendingBets = null,
    Object? isSubmitting = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
    Object? successMessage = freezed,
  }) {
    return _then(_$BetStateImpl(
      currentDraft: freezed == currentDraft
          ? _value.currentDraft
          : currentDraft // ignore: cast_nullable_to_non_nullable
              as BetDraftModel?,
      settledBets: null == settledBets
          ? _value._settledBets
          : settledBets // ignore: cast_nullable_to_non_nullable
              as List<BetModel>,
      pendingBets: null == pendingBets
          ? _value._pendingBets
          : pendingBets // ignore: cast_nullable_to_non_nullable
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

class _$BetStateImpl implements _BetState {
  const _$BetStateImpl(
      {this.currentDraft,
      final List<BetModel> settledBets = const [],
      final List<BetModel> pendingBets = const [],
      this.isSubmitting = false,
      this.isLoading = false,
      this.errorMessage,
      this.successMessage})
      : _settledBets = settledBets,
        _pendingBets = pendingBets;

// Đơn cược nháp đang nhập (chưa confirm)
  @override
  final BetDraftModel? currentDraft;
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

// Danh sách cược đang pending của bóng đá (giữ lại để tương thích)
  final List<BetModel> _pendingBets;
// Danh sách cược đang pending của bóng đá (giữ lại để tương thích)
  @override
  @JsonKey()
  List<BetModel> get pendingBets {
    if (_pendingBets is EqualUnmodifiableListView) return _pendingBets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pendingBets);
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
    return 'BetState(currentDraft: $currentDraft, settledBets: $settledBets, pendingBets: $pendingBets, isSubmitting: $isSubmitting, isLoading: $isLoading, errorMessage: $errorMessage, successMessage: $successMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BetStateImpl &&
            (identical(other.currentDraft, currentDraft) ||
                other.currentDraft == currentDraft) &&
            const DeepCollectionEquality()
                .equals(other._settledBets, _settledBets) &&
            const DeepCollectionEquality()
                .equals(other._pendingBets, _pendingBets) &&
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
      currentDraft,
      const DeepCollectionEquality().hash(_settledBets),
      const DeepCollectionEquality().hash(_pendingBets),
      isSubmitting,
      isLoading,
      errorMessage,
      successMessage);

  /// Create a copy of BetState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BetStateImplCopyWith<_$BetStateImpl> get copyWith =>
      __$$BetStateImplCopyWithImpl<_$BetStateImpl>(this, _$identity);
}

abstract class _BetState implements BetState {
  const factory _BetState(
      {final BetDraftModel? currentDraft,
      final List<BetModel> settledBets,
      final List<BetModel> pendingBets,
      final bool isSubmitting,
      final bool isLoading,
      final String? errorMessage,
      final String? successMessage}) = _$BetStateImpl;

// Đơn cược nháp đang nhập (chưa confirm)
  @override
  BetDraftModel? get currentDraft; // Lịch sử cược đã kết thúc
  @override
  List<BetModel>
      get settledBets; // Danh sách cược đang pending của bóng đá (giữ lại để tương thích)
  @override
  List<BetModel> get pendingBets;
  @override
  bool get isSubmitting;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  String? get successMessage;

  /// Create a copy of BetState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BetStateImplCopyWith<_$BetStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

BetDraftModel _$BetDraftModelFromJson(Map<String, dynamic> json) {
  return _BetDraftModel.fromJson(json);
}

/// @nodoc
mixin _$BetDraftModel {
  String? get matchId =>
      throw _privateConstructorUsedError; // null nếu là cược Tài Xỉu
  String? get sessionId =>
      throw _privateConstructorUsedError; // null nếu là cược Bóng đá
  BetChoice get choice => throw _privateConstructorUsedError; // over hoặc under
  double get amount => throw _privateConstructorUsedError;
  double get oddsAtTime => throw _privateConstructorUsedError;
  double get potentialPayout => throw _privateConstructorUsedError;

  /// Serializes this BetDraftModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BetDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BetDraftModelCopyWith<BetDraftModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BetDraftModelCopyWith<$Res> {
  factory $BetDraftModelCopyWith(
          BetDraftModel value, $Res Function(BetDraftModel) then) =
      _$BetDraftModelCopyWithImpl<$Res, BetDraftModel>;
  @useResult
  $Res call(
      {String? matchId,
      String? sessionId,
      BetChoice choice,
      double amount,
      double oddsAtTime,
      double potentialPayout});
}

/// @nodoc
class _$BetDraftModelCopyWithImpl<$Res, $Val extends BetDraftModel>
    implements $BetDraftModelCopyWith<$Res> {
  _$BetDraftModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BetDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = freezed,
    Object? sessionId = freezed,
    Object? choice = null,
    Object? amount = null,
    Object? oddsAtTime = null,
    Object? potentialPayout = null,
  }) {
    return _then(_value.copyWith(
      matchId: freezed == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      potentialPayout: null == potentialPayout
          ? _value.potentialPayout
          : potentialPayout // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BetDraftModelImplCopyWith<$Res>
    implements $BetDraftModelCopyWith<$Res> {
  factory _$$BetDraftModelImplCopyWith(
          _$BetDraftModelImpl value, $Res Function(_$BetDraftModelImpl) then) =
      __$$BetDraftModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? matchId,
      String? sessionId,
      BetChoice choice,
      double amount,
      double oddsAtTime,
      double potentialPayout});
}

/// @nodoc
class __$$BetDraftModelImplCopyWithImpl<$Res>
    extends _$BetDraftModelCopyWithImpl<$Res, _$BetDraftModelImpl>
    implements _$$BetDraftModelImplCopyWith<$Res> {
  __$$BetDraftModelImplCopyWithImpl(
      _$BetDraftModelImpl _value, $Res Function(_$BetDraftModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of BetDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? matchId = freezed,
    Object? sessionId = freezed,
    Object? choice = null,
    Object? amount = null,
    Object? oddsAtTime = null,
    Object? potentialPayout = null,
  }) {
    return _then(_$BetDraftModelImpl(
      matchId: freezed == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String?,
      sessionId: freezed == sessionId
          ? _value.sessionId
          : sessionId // ignore: cast_nullable_to_non_nullable
              as String?,
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
      potentialPayout: null == potentialPayout
          ? _value.potentialPayout
          : potentialPayout // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BetDraftModelImpl implements _BetDraftModel {
  const _$BetDraftModelImpl(
      {this.matchId,
      this.sessionId,
      required this.choice,
      required this.amount,
      required this.oddsAtTime,
      required this.potentialPayout});

  factory _$BetDraftModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$BetDraftModelImplFromJson(json);

  @override
  final String? matchId;
// null nếu là cược Tài Xỉu
  @override
  final String? sessionId;
// null nếu là cược Bóng đá
  @override
  final BetChoice choice;
// over hoặc under
  @override
  final double amount;
  @override
  final double oddsAtTime;
  @override
  final double potentialPayout;

  @override
  String toString() {
    return 'BetDraftModel(matchId: $matchId, sessionId: $sessionId, choice: $choice, amount: $amount, oddsAtTime: $oddsAtTime, potentialPayout: $potentialPayout)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BetDraftModelImpl &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.sessionId, sessionId) ||
                other.sessionId == sessionId) &&
            (identical(other.choice, choice) || other.choice == choice) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.oddsAtTime, oddsAtTime) ||
                other.oddsAtTime == oddsAtTime) &&
            (identical(other.potentialPayout, potentialPayout) ||
                other.potentialPayout == potentialPayout));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, matchId, sessionId, choice,
      amount, oddsAtTime, potentialPayout);

  /// Create a copy of BetDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BetDraftModelImplCopyWith<_$BetDraftModelImpl> get copyWith =>
      __$$BetDraftModelImplCopyWithImpl<_$BetDraftModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BetDraftModelImplToJson(
      this,
    );
  }
}

abstract class _BetDraftModel implements BetDraftModel {
  const factory _BetDraftModel(
      {final String? matchId,
      final String? sessionId,
      required final BetChoice choice,
      required final double amount,
      required final double oddsAtTime,
      required final double potentialPayout}) = _$BetDraftModelImpl;

  factory _BetDraftModel.fromJson(Map<String, dynamic> json) =
      _$BetDraftModelImpl.fromJson;

  @override
  String? get matchId; // null nếu là cược Tài Xỉu
  @override
  String? get sessionId; // null nếu là cược Bóng đá
  @override
  BetChoice get choice; // over hoặc under
  @override
  double get amount;
  @override
  double get oddsAtTime;
  @override
  double get potentialPayout;

  /// Create a copy of BetDraftModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BetDraftModelImplCopyWith<_$BetDraftModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
