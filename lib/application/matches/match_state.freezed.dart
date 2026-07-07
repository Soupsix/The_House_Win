// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$MatchState {
  List<MatchModel> get scheduledMatches => throw _privateConstructorUsedError;
  List<MatchModel> get liveMatches => throw _privateConstructorUsedError;
  List<MatchModel> get finishedMatches => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  MatchModel? get selectedMatch => throw _privateConstructorUsedError;
  DateTime? get lastSyncAt => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchStateCopyWith<MatchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchStateCopyWith<$Res> {
  factory $MatchStateCopyWith(
          MatchState value, $Res Function(MatchState) then) =
      _$MatchStateCopyWithImpl<$Res, MatchState>;
  @useResult
  $Res call(
      {List<MatchModel> scheduledMatches,
      List<MatchModel> liveMatches,
      List<MatchModel> finishedMatches,
      bool isRefreshing,
      MatchModel? selectedMatch,
      DateTime? lastSyncAt,
      String? errorMessage});

  $MatchModelCopyWith<$Res>? get selectedMatch;
}

/// @nodoc
class _$MatchStateCopyWithImpl<$Res, $Val extends MatchState>
    implements $MatchStateCopyWith<$Res> {
  _$MatchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledMatches = null,
    Object? liveMatches = null,
    Object? finishedMatches = null,
    Object? isRefreshing = null,
    Object? selectedMatch = freezed,
    Object? lastSyncAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      scheduledMatches: null == scheduledMatches
          ? _value.scheduledMatches
          : scheduledMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      liveMatches: null == liveMatches
          ? _value.liveMatches
          : liveMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      finishedMatches: null == finishedMatches
          ? _value.finishedMatches
          : finishedMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMatch: freezed == selectedMatch
          ? _value.selectedMatch
          : selectedMatch // ignore: cast_nullable_to_non_nullable
              as MatchModel?,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchModelCopyWith<$Res>? get selectedMatch {
    if (_value.selectedMatch == null) {
      return null;
    }

    return $MatchModelCopyWith<$Res>(_value.selectedMatch!, (value) {
      return _then(_value.copyWith(selectedMatch: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchStateImplCopyWith<$Res>
    implements $MatchStateCopyWith<$Res> {
  factory _$$MatchStateImplCopyWith(
          _$MatchStateImpl value, $Res Function(_$MatchStateImpl) then) =
      __$$MatchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<MatchModel> scheduledMatches,
      List<MatchModel> liveMatches,
      List<MatchModel> finishedMatches,
      bool isRefreshing,
      MatchModel? selectedMatch,
      DateTime? lastSyncAt,
      String? errorMessage});

  @override
  $MatchModelCopyWith<$Res>? get selectedMatch;
}

/// @nodoc
class __$$MatchStateImplCopyWithImpl<$Res>
    extends _$MatchStateCopyWithImpl<$Res, _$MatchStateImpl>
    implements _$$MatchStateImplCopyWith<$Res> {
  __$$MatchStateImplCopyWithImpl(
      _$MatchStateImpl _value, $Res Function(_$MatchStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? scheduledMatches = null,
    Object? liveMatches = null,
    Object? finishedMatches = null,
    Object? isRefreshing = null,
    Object? selectedMatch = freezed,
    Object? lastSyncAt = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$MatchStateImpl(
      scheduledMatches: null == scheduledMatches
          ? _value._scheduledMatches
          : scheduledMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      liveMatches: null == liveMatches
          ? _value._liveMatches
          : liveMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      finishedMatches: null == finishedMatches
          ? _value._finishedMatches
          : finishedMatches // ignore: cast_nullable_to_non_nullable
              as List<MatchModel>,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedMatch: freezed == selectedMatch
          ? _value.selectedMatch
          : selectedMatch // ignore: cast_nullable_to_non_nullable
              as MatchModel?,
      lastSyncAt: freezed == lastSyncAt
          ? _value.lastSyncAt
          : lastSyncAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$MatchStateImpl implements _MatchState {
  const _$MatchStateImpl(
      {final List<MatchModel> scheduledMatches = const [],
      final List<MatchModel> liveMatches = const [],
      final List<MatchModel> finishedMatches = const [],
      this.isRefreshing = false,
      this.selectedMatch,
      this.lastSyncAt,
      this.errorMessage})
      : _scheduledMatches = scheduledMatches,
        _liveMatches = liveMatches,
        _finishedMatches = finishedMatches;

  final List<MatchModel> _scheduledMatches;
  @override
  @JsonKey()
  List<MatchModel> get scheduledMatches {
    if (_scheduledMatches is EqualUnmodifiableListView)
      return _scheduledMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_scheduledMatches);
  }

  final List<MatchModel> _liveMatches;
  @override
  @JsonKey()
  List<MatchModel> get liveMatches {
    if (_liveMatches is EqualUnmodifiableListView) return _liveMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_liveMatches);
  }

  final List<MatchModel> _finishedMatches;
  @override
  @JsonKey()
  List<MatchModel> get finishedMatches {
    if (_finishedMatches is EqualUnmodifiableListView) return _finishedMatches;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_finishedMatches);
  }

  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final MatchModel? selectedMatch;
  @override
  final DateTime? lastSyncAt;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'MatchState(scheduledMatches: $scheduledMatches, liveMatches: $liveMatches, finishedMatches: $finishedMatches, isRefreshing: $isRefreshing, selectedMatch: $selectedMatch, lastSyncAt: $lastSyncAt, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchStateImpl &&
            const DeepCollectionEquality()
                .equals(other._scheduledMatches, _scheduledMatches) &&
            const DeepCollectionEquality()
                .equals(other._liveMatches, _liveMatches) &&
            const DeepCollectionEquality()
                .equals(other._finishedMatches, _finishedMatches) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.selectedMatch, selectedMatch) ||
                other.selectedMatch == selectedMatch) &&
            (identical(other.lastSyncAt, lastSyncAt) ||
                other.lastSyncAt == lastSyncAt) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_scheduledMatches),
      const DeepCollectionEquality().hash(_liveMatches),
      const DeepCollectionEquality().hash(_finishedMatches),
      isRefreshing,
      selectedMatch,
      lastSyncAt,
      errorMessage);

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchStateImplCopyWith<_$MatchStateImpl> get copyWith =>
      __$$MatchStateImplCopyWithImpl<_$MatchStateImpl>(this, _$identity);
}

abstract class _MatchState implements MatchState {
  const factory _MatchState(
      {final List<MatchModel> scheduledMatches,
      final List<MatchModel> liveMatches,
      final List<MatchModel> finishedMatches,
      final bool isRefreshing,
      final MatchModel? selectedMatch,
      final DateTime? lastSyncAt,
      final String? errorMessage}) = _$MatchStateImpl;

  @override
  List<MatchModel> get scheduledMatches;
  @override
  List<MatchModel> get liveMatches;
  @override
  List<MatchModel> get finishedMatches;
  @override
  bool get isRefreshing;
  @override
  MatchModel? get selectedMatch;
  @override
  DateTime? get lastSyncAt;
  @override
  String? get errorMessage;

  /// Create a copy of MatchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchStateImplCopyWith<_$MatchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
