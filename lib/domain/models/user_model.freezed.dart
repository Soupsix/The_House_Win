// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  String get uid => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  bool get isAdmin => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  DateTime? get fcmTokenUpdatedAt => throw _privateConstructorUsedError;
  NotificationSettingsModel get notificationSettings =>
      throw _privateConstructorUsedError;
  DateTime? get lastOpen => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      bool isAdmin,
      DateTime createdAt,
      String phoneNumber,
      String? fcmToken,
      DateTime? fcmTokenUpdatedAt,
      NotificationSettingsModel notificationSettings,
      DateTime? lastOpen});

  $NotificationSettingsModelCopyWith<$Res> get notificationSettings;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? isAdmin = null,
    Object? createdAt = null,
    Object? phoneNumber = null,
    Object? fcmToken = freezed,
    Object? fcmTokenUpdatedAt = freezed,
    Object? notificationSettings = null,
    Object? lastOpen = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmTokenUpdatedAt: freezed == fcmTokenUpdatedAt
          ? _value.fcmTokenUpdatedAt
          : fcmTokenUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationSettings: null == notificationSettings
          ? _value.notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as NotificationSettingsModel,
      lastOpen: freezed == lastOpen
          ? _value.lastOpen
          : lastOpen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NotificationSettingsModelCopyWith<$Res> get notificationSettings {
    return $NotificationSettingsModelCopyWith<$Res>(_value.notificationSettings,
        (value) {
      return _then(_value.copyWith(notificationSettings: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String email,
      String displayName,
      bool isAdmin,
      DateTime createdAt,
      String phoneNumber,
      String? fcmToken,
      DateTime? fcmTokenUpdatedAt,
      NotificationSettingsModel notificationSettings,
      DateTime? lastOpen});

  @override
  $NotificationSettingsModelCopyWith<$Res> get notificationSettings;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? email = null,
    Object? displayName = null,
    Object? isAdmin = null,
    Object? createdAt = null,
    Object? phoneNumber = null,
    Object? fcmToken = freezed,
    Object? fcmTokenUpdatedAt = freezed,
    Object? notificationSettings = null,
    Object? lastOpen = freezed,
  }) {
    return _then(_$UserModelImpl(
      uid: null == uid
          ? _value.uid
          : uid // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      isAdmin: null == isAdmin
          ? _value.isAdmin
          : isAdmin // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmTokenUpdatedAt: freezed == fcmTokenUpdatedAt
          ? _value.fcmTokenUpdatedAt
          : fcmTokenUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      notificationSettings: null == notificationSettings
          ? _value.notificationSettings
          : notificationSettings // ignore: cast_nullable_to_non_nullable
              as NotificationSettingsModel,
      lastOpen: freezed == lastOpen
          ? _value.lastOpen
          : lastOpen // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.uid,
      required this.email,
      required this.displayName,
      required this.isAdmin,
      required this.createdAt,
      required this.phoneNumber,
      this.fcmToken,
      this.fcmTokenUpdatedAt,
      this.notificationSettings = const NotificationSettingsModel(),
      this.lastOpen});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final String uid;
  @override
  final String email;
  @override
  final String displayName;
  @override
  final bool isAdmin;
  @override
  final DateTime createdAt;
  @override
  final String phoneNumber;
  @override
  final String? fcmToken;
  @override
  final DateTime? fcmTokenUpdatedAt;
  @override
  @JsonKey()
  final NotificationSettingsModel notificationSettings;
  @override
  final DateTime? lastOpen;

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, isAdmin: $isAdmin, createdAt: $createdAt, phoneNumber: $phoneNumber, fcmToken: $fcmToken, fcmTokenUpdatedAt: $fcmTokenUpdatedAt, notificationSettings: $notificationSettings, lastOpen: $lastOpen)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.fcmTokenUpdatedAt, fcmTokenUpdatedAt) ||
                other.fcmTokenUpdatedAt == fcmTokenUpdatedAt) &&
            (identical(other.notificationSettings, notificationSettings) ||
                other.notificationSettings == notificationSettings) &&
            (identical(other.lastOpen, lastOpen) ||
                other.lastOpen == lastOpen));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      email,
      displayName,
      isAdmin,
      createdAt,
      phoneNumber,
      fcmToken,
      fcmTokenUpdatedAt,
      notificationSettings,
      lastOpen);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final String uid,
      required final String email,
      required final String displayName,
      required final bool isAdmin,
      required final DateTime createdAt,
      required final String phoneNumber,
      final String? fcmToken,
      final DateTime? fcmTokenUpdatedAt,
      final NotificationSettingsModel notificationSettings,
      final DateTime? lastOpen}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  String get uid;
  @override
  String get email;
  @override
  String get displayName;
  @override
  bool get isAdmin;
  @override
  DateTime get createdAt;
  @override
  String get phoneNumber;
  @override
  String? get fcmToken;
  @override
  DateTime? get fcmTokenUpdatedAt;
  @override
  NotificationSettingsModel get notificationSettings;
  @override
  DateTime? get lastOpen;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
