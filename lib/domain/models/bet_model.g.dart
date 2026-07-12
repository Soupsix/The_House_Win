// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bet_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BetModelImpl _$$BetModelImplFromJson(Map<String, dynamic> json) =>
    _$BetModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      matchId: json['matchId'] as String?,
      homeTeam: json['homeTeam'] as String?,
      awayTeam: json['awayTeam'] as String?,
      sessionId: json['sessionId'] as String?,
      sessionNumber: (json['sessionNumber'] as num?)?.toInt(),
      choice: $enumDecode(_$BetChoiceEnumMap, json['choice']),
      amount: (json['amount'] as num).toDouble(),
      oddsAtTime: (json['oddsAtTime'] as num).toDouble(),
      payout: (json['payout'] as num?)?.toDouble() ?? 0.0,
      status: $enumDecode(_$BetStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      settledAt: json['settledAt'] == null
          ? null
          : DateTime.parse(json['settledAt'] as String),
    );

Map<String, dynamic> _$$BetModelImplToJson(_$BetModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'matchId': instance.matchId,
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'sessionId': instance.sessionId,
      'sessionNumber': instance.sessionNumber,
      'choice': _$BetChoiceEnumMap[instance.choice]!,
      'amount': instance.amount,
      'oddsAtTime': instance.oddsAtTime,
      'payout': instance.payout,
      'status': _$BetStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'settledAt': instance.settledAt?.toIso8601String(),
    };

const _$BetChoiceEnumMap = {
  BetChoice.over: 'over',
  BetChoice.under: 'under',
  BetChoice.draw: 'draw',
};

const _$BetStatusEnumMap = {
  BetStatus.pending: 'pending',
  BetStatus.won: 'won',
  BetStatus.lost: 'lost',
  BetStatus.push: 'push',
};
