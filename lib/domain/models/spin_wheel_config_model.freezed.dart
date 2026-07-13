// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spin_wheel_config_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpinWheelConfigModel _$SpinWheelConfigModelFromJson(Map<String, dynamic> json) {
  return _SpinWheelConfigModel.fromJson(json);
}

/// @nodoc
mixin _$SpinWheelConfigModel {
  String get id => throw _privateConstructorUsedError;
  List<SpinSegmentModel> get segments => throw _privateConstructorUsedError;
  double get minBet => throw _privateConstructorUsedError;
  double get maxBet => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this SpinWheelConfigModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpinWheelConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpinWheelConfigModelCopyWith<SpinWheelConfigModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpinWheelConfigModelCopyWith<$Res> {
  factory $SpinWheelConfigModelCopyWith(SpinWheelConfigModel value,
          $Res Function(SpinWheelConfigModel) then) =
      _$SpinWheelConfigModelCopyWithImpl<$Res, SpinWheelConfigModel>;
  @useResult
  $Res call(
      {String id,
      List<SpinSegmentModel> segments,
      double minBet,
      double maxBet,
      bool isActive});
}

/// @nodoc
class _$SpinWheelConfigModelCopyWithImpl<$Res,
        $Val extends SpinWheelConfigModel>
    implements $SpinWheelConfigModelCopyWith<$Res> {
  _$SpinWheelConfigModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpinWheelConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? segments = null,
    Object? minBet = null,
    Object? maxBet = null,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      segments: null == segments
          ? _value.segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<SpinSegmentModel>,
      minBet: null == minBet
          ? _value.minBet
          : minBet // ignore: cast_nullable_to_non_nullable
              as double,
      maxBet: null == maxBet
          ? _value.maxBet
          : maxBet // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpinWheelConfigModelImplCopyWith<$Res>
    implements $SpinWheelConfigModelCopyWith<$Res> {
  factory _$$SpinWheelConfigModelImplCopyWith(_$SpinWheelConfigModelImpl value,
          $Res Function(_$SpinWheelConfigModelImpl) then) =
      __$$SpinWheelConfigModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      List<SpinSegmentModel> segments,
      double minBet,
      double maxBet,
      bool isActive});
}

/// @nodoc
class __$$SpinWheelConfigModelImplCopyWithImpl<$Res>
    extends _$SpinWheelConfigModelCopyWithImpl<$Res, _$SpinWheelConfigModelImpl>
    implements _$$SpinWheelConfigModelImplCopyWith<$Res> {
  __$$SpinWheelConfigModelImplCopyWithImpl(_$SpinWheelConfigModelImpl _value,
      $Res Function(_$SpinWheelConfigModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpinWheelConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? segments = null,
    Object? minBet = null,
    Object? maxBet = null,
    Object? isActive = null,
  }) {
    return _then(_$SpinWheelConfigModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      segments: null == segments
          ? _value._segments
          : segments // ignore: cast_nullable_to_non_nullable
              as List<SpinSegmentModel>,
      minBet: null == minBet
          ? _value.minBet
          : minBet // ignore: cast_nullable_to_non_nullable
              as double,
      maxBet: null == maxBet
          ? _value.maxBet
          : maxBet // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpinWheelConfigModelImpl implements _SpinWheelConfigModel {
  const _$SpinWheelConfigModelImpl(
      {required this.id,
      required final List<SpinSegmentModel> segments,
      required this.minBet,
      required this.maxBet,
      this.isActive = true})
      : _segments = segments;

  factory _$SpinWheelConfigModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpinWheelConfigModelImplFromJson(json);

  @override
  final String id;
  final List<SpinSegmentModel> _segments;
  @override
  List<SpinSegmentModel> get segments {
    if (_segments is EqualUnmodifiableListView) return _segments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_segments);
  }

  @override
  final double minBet;
  @override
  final double maxBet;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'SpinWheelConfigModel(id: $id, segments: $segments, minBet: $minBet, maxBet: $maxBet, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpinWheelConfigModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(other._segments, _segments) &&
            (identical(other.minBet, minBet) || other.minBet == minBet) &&
            (identical(other.maxBet, maxBet) || other.maxBet == maxBet) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id,
      const DeepCollectionEquality().hash(_segments), minBet, maxBet, isActive);

  /// Create a copy of SpinWheelConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpinWheelConfigModelImplCopyWith<_$SpinWheelConfigModelImpl>
      get copyWith =>
          __$$SpinWheelConfigModelImplCopyWithImpl<_$SpinWheelConfigModelImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpinWheelConfigModelImplToJson(
      this,
    );
  }
}

abstract class _SpinWheelConfigModel implements SpinWheelConfigModel {
  const factory _SpinWheelConfigModel(
      {required final String id,
      required final List<SpinSegmentModel> segments,
      required final double minBet,
      required final double maxBet,
      final bool isActive}) = _$SpinWheelConfigModelImpl;

  factory _SpinWheelConfigModel.fromJson(Map<String, dynamic> json) =
      _$SpinWheelConfigModelImpl.fromJson;

  @override
  String get id;
  @override
  List<SpinSegmentModel> get segments;
  @override
  double get minBet;
  @override
  double get maxBet;
  @override
  bool get isActive;

  /// Create a copy of SpinWheelConfigModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpinWheelConfigModelImplCopyWith<_$SpinWheelConfigModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
