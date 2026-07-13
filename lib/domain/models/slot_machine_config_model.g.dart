// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_machine_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotMachineConfigModelImpl _$$SlotMachineConfigModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SlotMachineConfigModelImpl(
      id: json['id'] as String,
      symbols: (json['symbols'] as List<dynamic>)
          .map((e) => SlotSymbolModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      reelCount: (json['reelCount'] as num).toInt(),
      fixedBet: (json['fixedBet'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$$SlotMachineConfigModelImplToJson(
        _$SlotMachineConfigModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'symbols': instance.symbols,
      'reelCount': instance.reelCount,
      'fixedBet': instance.fixedBet,
      'isActive': instance.isActive,
    };
