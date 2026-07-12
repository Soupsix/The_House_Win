// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BetDraftModelImpl _$$BetDraftModelImplFromJson(Map<String, dynamic> json) =>
    _$BetDraftModelImpl(
      matchId: json['matchId'] as String?,
      sessionId: json['sessionId'] as String?,
      choice: $enumDecode(_$BetChoiceEnumMap, json['choice']),
      amount: (json['amount'] as num).toDouble(),
      oddsAtTime: (json['oddsAtTime'] as num).toDouble(),
      potentialPayout: (json['potentialPayout'] as num).toDouble(),
    );

Map<String, dynamic> _$$BetDraftModelImplToJson(_$BetDraftModelImpl instance) =>
    <String, dynamic>{
      'matchId': instance.matchId,
      'sessionId': instance.sessionId,
      'choice': _$BetChoiceEnumMap[instance.choice]!,
      'amount': instance.amount,
      'oddsAtTime': instance.oddsAtTime,
      'potentialPayout': instance.potentialPayout,
    };

const _$BetChoiceEnumMap = {
  BetChoice.over: 'over',
  BetChoice.under: 'under',
  BetChoice.draw: 'draw',
};
