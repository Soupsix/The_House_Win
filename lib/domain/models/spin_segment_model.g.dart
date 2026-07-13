// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spin_segment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpinSegmentModelImpl _$$SpinSegmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpinSegmentModelImpl(
      id: json['id'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      probability: (json['probability'] as num).toDouble(),
      label: json['label'] as String,
      colorHex: json['colorHex'] as String,
    );

Map<String, dynamic> _$$SpinSegmentModelImplToJson(
        _$SpinSegmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'multiplier': instance.multiplier,
      'probability': instance.probability,
      'label': instance.label,
      'colorHex': instance.colorHex,
    };
