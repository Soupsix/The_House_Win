// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_history_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationHistoryModel _$NotificationHistoryModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationHistoryModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationHistoryModel {
  int? get id => throw _privateConstructorUsedError; // SQLite primary key
  String get title => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  DateTime get receivedAt => throw _privateConstructorUsedError;
  bool get isRead => throw _privateConstructorUsedError;
  String? get payload => throw _privateConstructorUsedError;

  /// Serializes this NotificationHistoryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationHistoryModelCopyWith<NotificationHistoryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationHistoryModelCopyWith<$Res> {
  factory $NotificationHistoryModelCopyWith(NotificationHistoryModel value,
          $Res Function(NotificationHistoryModel) then) =
      _$NotificationHistoryModelCopyWithImpl<$Res, NotificationHistoryModel>;
  @useResult
  $Res call(
      {int? id,
      String title,
      String body,
      String type,
      DateTime receivedAt,
      bool isRead,
      String? payload});
}

/// @nodoc
class _$NotificationHistoryModelCopyWithImpl<$Res,
        $Val extends NotificationHistoryModel>
    implements $NotificationHistoryModelCopyWith<$Res> {
  _$NotificationHistoryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? receivedAt = null,
    Object? isRead = null,
    Object? payload = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      receivedAt: null == receivedAt
          ? _value.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationHistoryModelImplCopyWith<$Res>
    implements $NotificationHistoryModelCopyWith<$Res> {
  factory _$$NotificationHistoryModelImplCopyWith(
          _$NotificationHistoryModelImpl value,
          $Res Function(_$NotificationHistoryModelImpl) then) =
      __$$NotificationHistoryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int? id,
      String title,
      String body,
      String type,
      DateTime receivedAt,
      bool isRead,
      String? payload});
}

/// @nodoc
class __$$NotificationHistoryModelImplCopyWithImpl<$Res>
    extends _$NotificationHistoryModelCopyWithImpl<$Res,
        _$NotificationHistoryModelImpl>
    implements _$$NotificationHistoryModelImplCopyWith<$Res> {
  __$$NotificationHistoryModelImplCopyWithImpl(
      _$NotificationHistoryModelImpl _value,
      $Res Function(_$NotificationHistoryModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? title = null,
    Object? body = null,
    Object? type = null,
    Object? receivedAt = null,
    Object? isRead = null,
    Object? payload = freezed,
  }) {
    return _then(_$NotificationHistoryModelImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      receivedAt: null == receivedAt
          ? _value.receivedAt
          : receivedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _value.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      payload: freezed == payload
          ? _value.payload
          : payload // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationHistoryModelImpl implements _NotificationHistoryModel {
  const _$NotificationHistoryModelImpl(
      {this.id,
      required this.title,
      required this.body,
      required this.type,
      required this.receivedAt,
      this.isRead = false,
      this.payload});

  factory _$NotificationHistoryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationHistoryModelImplFromJson(json);

  @override
  final int? id;
// SQLite primary key
  @override
  final String title;
  @override
  final String body;
  @override
  final String type;
  @override
  final DateTime receivedAt;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? payload;

  @override
  String toString() {
    return 'NotificationHistoryModel(id: $id, title: $title, body: $body, type: $type, receivedAt: $receivedAt, isRead: $isRead, payload: $payload)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationHistoryModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.receivedAt, receivedAt) ||
                other.receivedAt == receivedAt) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.payload, payload) || other.payload == payload));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, title, body, type, receivedAt, isRead, payload);

  /// Create a copy of NotificationHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationHistoryModelImplCopyWith<_$NotificationHistoryModelImpl>
      get copyWith => __$$NotificationHistoryModelImplCopyWithImpl<
          _$NotificationHistoryModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationHistoryModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationHistoryModel implements NotificationHistoryModel {
  const factory _NotificationHistoryModel(
      {final int? id,
      required final String title,
      required final String body,
      required final String type,
      required final DateTime receivedAt,
      final bool isRead,
      final String? payload}) = _$NotificationHistoryModelImpl;

  factory _NotificationHistoryModel.fromJson(Map<String, dynamic> json) =
      _$NotificationHistoryModelImpl.fromJson;

  @override
  int? get id; // SQLite primary key
  @override
  String get title;
  @override
  String get body;
  @override
  String get type;
  @override
  DateTime get receivedAt;
  @override
  bool get isRead;
  @override
  String? get payload;

  /// Create a copy of NotificationHistoryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationHistoryModelImplCopyWith<_$NotificationHistoryModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
