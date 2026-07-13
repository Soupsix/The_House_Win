// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SlotResultModelImpl _$$SlotResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SlotResultModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      betAmount: (json['betAmount'] as num).toDouble(),
      reelSymbolIds: (json['reelSymbolIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      multiplier: (json['multiplier'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$$SlotResultModelImplToJson(
        _$SlotResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'betAmount': instance.betAmount,
      'reelSymbolIds': instance.reelSymbolIds,
      'multiplier': instance.multiplier,
      'payout': instance.payout,
      'createdAt': instance.createdAt.toIso8601String(),
      'transactionId': instance.transactionId,
    };
