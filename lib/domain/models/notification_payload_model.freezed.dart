// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_payload_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

NotificationPayloadModel _$NotificationPayloadModelFromJson(
    Map<String, dynamic> json) {
  return _NotificationPayloadModel.fromJson(json);
}

/// @nodoc
mixin _$NotificationPayloadModel {
  String get type => throw _privateConstructorUsedError;
  String? get route => throw _privateConstructorUsedError;
  String? get referenceId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get extraData => throw _privateConstructorUsedError;

  /// Serializes this NotificationPayloadModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NotificationPayloadModelCopyWith<NotificationPayloadModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotificationPayloadModelCopyWith<$Res> {
  factory $NotificationPayloadModelCopyWith(NotificationPayloadModel value,
          $Res Function(NotificationPayloadModel) then) =
      _$NotificationPayloadModelCopyWithImpl<$Res, NotificationPayloadModel>;
  @useResult
  $Res call(
      {String type,
      String? route,
      String? referenceId,
      Map<String, dynamic>? extraData});
}

/// @nodoc
class _$NotificationPayloadModelCopyWithImpl<$Res,
        $Val extends NotificationPayloadModel>
    implements $NotificationPayloadModelCopyWith<$Res> {
  _$NotificationPayloadModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? route = freezed,
    Object? referenceId = freezed,
    Object? extraData = freezed,
  }) {
    return _then(_value.copyWith(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      extraData: freezed == extraData
          ? _value.extraData
          : extraData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotificationPayloadModelImplCopyWith<$Res>
    implements $NotificationPayloadModelCopyWith<$Res> {
  factory _$$NotificationPayloadModelImplCopyWith(
          _$NotificationPayloadModelImpl value,
          $Res Function(_$NotificationPayloadModelImpl) then) =
      __$$NotificationPayloadModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String type,
      String? route,
      String? referenceId,
      Map<String, dynamic>? extraData});
}

/// @nodoc
class __$$NotificationPayloadModelImplCopyWithImpl<$Res>
    extends _$NotificationPayloadModelCopyWithImpl<$Res,
        _$NotificationPayloadModelImpl>
    implements _$$NotificationPayloadModelImplCopyWith<$Res> {
  __$$NotificationPayloadModelImplCopyWithImpl(
      _$NotificationPayloadModelImpl _value,
      $Res Function(_$NotificationPayloadModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? route = freezed,
    Object? referenceId = freezed,
    Object? extraData = freezed,
  }) {
    return _then(_$NotificationPayloadModelImpl(
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      route: freezed == route
          ? _value.route
          : route // ignore: cast_nullable_to_non_nullable
              as String?,
      referenceId: freezed == referenceId
          ? _value.referenceId
          : referenceId // ignore: cast_nullable_to_non_nullable
              as String?,
      extraData: freezed == extraData
          ? _value._extraData
          : extraData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NotificationPayloadModelImpl implements _NotificationPayloadModel {
  const _$NotificationPayloadModelImpl(
      {required this.type,
      this.route,
      this.referenceId,
      final Map<String, dynamic>? extraData})
      : _extraData = extraData;

  factory _$NotificationPayloadModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$NotificationPayloadModelImplFromJson(json);

  @override
  final String type;
  @override
  final String? route;
  @override
  final String? referenceId;
  final Map<String, dynamic>? _extraData;
  @override
  Map<String, dynamic>? get extraData {
    final value = _extraData;
    if (value == null) return null;
    if (_extraData is EqualUnmodifiableMapView) return _extraData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'NotificationPayloadModel(type: $type, route: $route, referenceId: $referenceId, extraData: $extraData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotificationPayloadModelImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.route, route) || other.route == route) &&
            (identical(other.referenceId, referenceId) ||
                other.referenceId == referenceId) &&
            const DeepCollectionEquality()
                .equals(other._extraData, _extraData));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, route, referenceId,
      const DeepCollectionEquality().hash(_extraData));

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NotificationPayloadModelImplCopyWith<_$NotificationPayloadModelImpl>
      get copyWith => __$$NotificationPayloadModelImplCopyWithImpl<
          _$NotificationPayloadModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NotificationPayloadModelImplToJson(
      this,
    );
  }
}

abstract class _NotificationPayloadModel implements NotificationPayloadModel {
  const factory _NotificationPayloadModel(
      {required final String type,
      final String? route,
      final String? referenceId,
      final Map<String, dynamic>? extraData}) = _$NotificationPayloadModelImpl;

  factory _NotificationPayloadModel.fromJson(Map<String, dynamic> json) =
      _$NotificationPayloadModelImpl.fromJson;

  @override
  String get type;
  @override
  String? get route;
  @override
  String? get referenceId;
  @override
  Map<String, dynamic>? get extraData;

  /// Create a copy of NotificationPayloadModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NotificationPayloadModelImplCopyWith<_$NotificationPayloadModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
