// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionModelImpl _$$TransactionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$TransactionModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      referenceId: json['referenceId'] as String?,
      gameType: $enumDecodeNullable(_$GameTypeEnumMap, json['gameType']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$TransactionModelImplToJson(
        _$TransactionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'amount': instance.amount,
      'referenceId': instance.referenceId,
      'gameType': _$GameTypeEnumMap[instance.gameType],
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$GameTypeEnumMap = {
  GameType.diceOverUnder: 'diceOverUnder',
  GameType.spinWheel: 'spinWheel',
  GameType.slotMachine: 'slotMachine',
};
