// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'spin_segment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SpinSegmentModel _$SpinSegmentModelFromJson(Map<String, dynamic> json) {
  return _SpinSegmentModel.fromJson(json);
}

/// @nodoc
mixin _$SpinSegmentModel {
  String get id => throw _privateConstructorUsedError;
  double get multiplier =>
      throw _privateConstructorUsedError; // 0 = mất hết, 1 = hòa, 2.5 = x2.5...
  double get probability =>
      throw _privateConstructorUsedError; // tổng tất cả segment = 1.0
  String get label =>
      throw _privateConstructorUsedError; // "x0", "x2", "JACKPOT x10"
  String get colorHex => throw _privateConstructorUsedError;

  /// Serializes this SpinSegmentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SpinSegmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SpinSegmentModelCopyWith<SpinSegmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SpinSegmentModelCopyWith<$Res> {
  factory $SpinSegmentModelCopyWith(
          SpinSegmentModel value, $Res Function(SpinSegmentModel) then) =
      _$SpinSegmentModelCopyWithImpl<$Res, SpinSegmentModel>;
  @useResult
  $Res call(
      {String id,
      double multiplier,
      double probability,
      String label,
      String colorHex});
}

/// @nodoc
class _$SpinSegmentModelCopyWithImpl<$Res, $Val extends SpinSegmentModel>
    implements $SpinSegmentModelCopyWith<$Res> {
  _$SpinSegmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SpinSegmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? multiplier = null,
    Object? probability = null,
    Object? label = null,
    Object? colorHex = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SpinSegmentModelImplCopyWith<$Res>
    implements $SpinSegmentModelCopyWith<$Res> {
  factory _$$SpinSegmentModelImplCopyWith(_$SpinSegmentModelImpl value,
          $Res Function(_$SpinSegmentModelImpl) then) =
      __$$SpinSegmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double multiplier,
      double probability,
      String label,
      String colorHex});
}

/// @nodoc
class __$$SpinSegmentModelImplCopyWithImpl<$Res>
    extends _$SpinSegmentModelCopyWithImpl<$Res, _$SpinSegmentModelImpl>
    implements _$$SpinSegmentModelImplCopyWith<$Res> {
  __$$SpinSegmentModelImplCopyWithImpl(_$SpinSegmentModelImpl _value,
      $Res Function(_$SpinSegmentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of SpinSegmentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? multiplier = null,
    Object? probability = null,
    Object? label = null,
    Object? colorHex = null,
  }) {
    return _then(_$SpinSegmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      multiplier: null == multiplier
          ? _value.multiplier
          : multiplier // ignore: cast_nullable_to_non_nullable
              as double,
      probability: null == probability
          ? _value.probability
          : probability // ignore: cast_nullable_to_non_nullable
              as double,
      label: null == label
          ? _value.label
          : label // ignore: cast_nullable_to_non_nullable
              as String,
      colorHex: null == colorHex
          ? _value.colorHex
          : colorHex // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SpinSegmentModelImpl implements _SpinSegmentModel {
  const _$SpinSegmentModelImpl(
      {required this.id,
      required this.multiplier,
      required this.probability,
      required this.label,
      required this.colorHex});

  factory _$SpinSegmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SpinSegmentModelImplFromJson(json);

  @override
  final String id;
  @override
  final double multiplier;
// 0 = mất hết, 1 = hòa, 2.5 = x2.5...
  @override
  final double probability;
// tổng tất cả segment = 1.0
  @override
  final String label;
// "x0", "x2", "JACKPOT x10"
  @override
  final String colorHex;

  @override
  String toString() {
    return 'SpinSegmentModel(id: $id, multiplier: $multiplier, probability: $probability, label: $label, colorHex: $colorHex)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SpinSegmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.multiplier, multiplier) ||
                other.multiplier == multiplier) &&
            (identical(other.probability, probability) ||
                other.probability == probability) &&
            (identical(other.label, label) || other.label == label) &&
            (identical(other.colorHex, colorHex) ||
                other.colorHex == colorHex));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, multiplier, probability, label, colorHex);

  /// Create a copy of SpinSegmentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SpinSegmentModelImplCopyWith<_$SpinSegmentModelImpl> get copyWith =>
      __$$SpinSegmentModelImplCopyWithImpl<_$SpinSegmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SpinSegmentModelImplToJson(
      this,
    );
  }
}

abstract class _SpinSegmentModel implements SpinSegmentModel {
  const factory _SpinSegmentModel(
      {required final String id,
      required final double multiplier,
      required final double probability,
      required final String label,
      required final String colorHex}) = _$SpinSegmentModelImpl;

  factory _SpinSegmentModel.fromJson(Map<String, dynamic> json) =
      _$SpinSegmentModelImpl.fromJson;

  @override
  String get id;
  @override
  double get multiplier; // 0 = mất hết, 1 = hòa, 2.5 = x2.5...
  @override
  double get probability; // tổng tất cả segment = 1.0
  @override
  String get label; // "x0", "x2", "JACKPOT x10"
  @override
  String get colorHex;

  /// Create a copy of SpinSegmentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SpinSegmentModelImplCopyWith<_$SpinSegmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
