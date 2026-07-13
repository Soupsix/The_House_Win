// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_history_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotificationHistoryState {
  bool get isLoading => throw _privateConstructorUsedError;
  List<NotificationHistoryModel> get notifications =>
      throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of NotificationHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationHistoryStateCopyWith<NotificationHistoryState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationHistoryStateCopyWith<$Res> {
  factory $NotificationHistoryStateCopyWith(NotificationHistoryState value,
          $Res Function(NotificationHistoryState) then) =
      _$NotificationHistoryStateCopyWithImpl<$Res, NotificationHistoryState>;
  @useResult
  $Res call(
      {bool isLoading,
      List<NotificationHistoryModel> notifications,
      String? errorMessage});
}

/// @nodoc
class _$NotificationHistoryStateCopyWithImpl<$Res,
        $Val extends NotificationHistoryState>
    implements $NotificationHistoryStateCopyWith<$Res> {
  _$NotificationHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? notifications = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      notifications: null == notifications
          ? _value.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationHistoryModel>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationHistoryStateImplCopyWith<$Res>
    implements $NotificationHistoryStateCopyWith<$Res> {
  factory _$$NotificationHistoryStateImplCopyWith(
          _$NotificationHistoryStateImpl value,
          $Res Function(_$NotificationHistoryStateImpl) then) =
      __$$NotificationHistoryStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLoading,
      List<NotificationHistoryModel> notifications,
      String? errorMessage});
}

/// @nodoc
class __$$NotificationHistoryStateImplCopyWithImpl<$Res>
    extends _$NotificationHistoryStateCopyWithImpl<$Res,
        _$NotificationHistoryStateImpl>
    implements _$$NotificationHistoryStateImplCopyWith<$Res> {
  __$$NotificationHistoryStateImplCopyWithImpl(
      _$NotificationHistoryStateImpl _value,
      $Res Function(_$NotificationHistoryStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? notifications = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$NotificationHistoryStateImpl(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      notifications: null == notifications
          ? _value._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationHistoryModel>,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$NotificationHistoryStateImpl implements _NotificationHistoryState {
  const _$NotificationHistoryStateImpl(
      {this.isLoading = true,
      final List<NotificationHistoryModel> notifications = const [],
      this.errorMessage})
      : _notifications = notifications;

  @override
  @JsonKey()
  final bool isLoading;
  final List<NotificationHistoryModel> _notifications;
  @override
  @JsonKey()
  List<NotificationHistoryModel> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'NotificationHistoryState(isLoading: $isLoading, notifications: $notifications, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationHistoryStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading,
      const DeepCollectionEquality().hash(_notifications), errorMessage);

  /// Create a copy of NotificationHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationHistoryStateImplCopyWith<_$NotificationHistoryStateImpl>
      get copyWith => __$$NotificationHistoryStateImplCopyWithImpl<
          _$NotificationHistoryStateImpl>(this, _$identity);
}

abstract class _NotificationHistoryState implements NotificationHistoryState {
  const factory _NotificationHistoryState(
      {final bool isLoading,
      final List<NotificationHistoryModel> notifications,
      final String? errorMessage}) = _$NotificationHistoryStateImpl;

  @override
  bool get isLoading;
  @override
  List<NotificationHistoryModel> get notifications;
  @override
  String? get errorMessage;

  /// Create a copy of NotificationHistoryState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationHistoryStateImplCopyWith<_$NotificationHistoryStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
