// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchModelImpl _$$MatchModelImplFromJson(Map<String, dynamic> json) =>
    _$MatchModelImpl(
      id: json['id'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      utcDate: DateTime.parse(json['utcDate'] as String),
      status: $enumDecode(_$MatchStatusEnumMap, json['status']),
      scoreHome: (json['scoreHome'] as num?)?.toInt() ?? 0,
      scoreAway: (json['scoreAway'] as num?)?.toInt() ?? 0,
      result: $enumDecodeNullable(_$MatchResultEnumMap, json['result']),
      oddsOver: (json['oddsOver'] as num).toDouble(),
      oddsUnder: (json['oddsUnder'] as num).toDouble(),
      overUnderLine: (json['overUnderLine'] as num).toDouble(),
      isSimulated: json['isSimulated'] as bool? ?? false,
    );

Map<String, dynamic> _$$MatchModelImplToJson(_$MatchModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'homeTeam': instance.homeTeam,
      'awayTeam': instance.awayTeam,
      'utcDate': instance.utcDate.toIso8601String(),
      'status': _$MatchStatusEnumMap[instance.status]!,
      'scoreHome': instance.scoreHome,
      'scoreAway': instance.scoreAway,
      'result': _$MatchResultEnumMap[instance.result],
      'oddsOver': instance.oddsOver,
      'oddsUnder': instance.oddsUnder,
      'overUnderLine': instance.overUnderLine,
      'isSimulated': instance.isSimulated,
    };

const _$MatchStatusEnumMap = {
  MatchStatus.scheduled: 'scheduled',
  MatchStatus.inPlay: 'inPlay',
  MatchStatus.finished: 'finished',
};

const _$MatchResultEnumMap = {
  MatchResult.over: 'over',
  MatchResult.under: 'under',
  MatchResult.push: 'push',
};
