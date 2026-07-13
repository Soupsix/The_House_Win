// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spin_wheel_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpinWheelConfigModelImpl _$$SpinWheelConfigModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpinWheelConfigModelImpl(
      id: json['id'] as String,
      segments: (json['segments'] as List<dynamic>)
          .map((e) => SpinSegmentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      minBet: (json['minBet'] as num).toDouble(),
      maxBet: (json['maxBet'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$SpinWheelConfigModelImplToJson(
        _$SpinWheelConfigModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'segments': instance.segments,
      'minBet': instance.minBet,
      'maxBet': instance.maxBet,
      'isActive': instance.isActive,
    };
