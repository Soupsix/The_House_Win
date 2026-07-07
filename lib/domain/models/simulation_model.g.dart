// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'simulation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SimulationResultModelImpl _$$SimulationResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SimulationResultModelImpl(
      avgFinalBalance: (json['avgFinalBalance'] as num).toDouble(),
      bustCount: (json['bustCount'] as num).toInt(),
      profitCount: (json['profitCount'] as num).toInt(),
      houseEdge: (json['houseEdge'] as num).toDouble(),
      expectedValue: (json['expectedValue'] as num).toDouble(),
      runAt: DateTime.parse(json['runAt'] as String),
    );

Map<String, dynamic> _$$SimulationResultModelImplToJson(
        _$SimulationResultModelImpl instance) =>
    <String, dynamic>{
      'avgFinalBalance': instance.avgFinalBalance,
      'bustCount': instance.bustCount,
      'profitCount': instance.profitCount,
      'houseEdge': instance.houseEdge,
      'expectedValue': instance.expectedValue,
      'runAt': instance.runAt.toIso8601String(),
    };
