// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'betting_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BettingSessionModelImpl _$$BettingSessionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$BettingSessionModelImpl(
      sessionId: json['sessionId'] as String,
      sessionNumber: (json['sessionNumber'] as num).toInt(),
      status: $enumDecode(_$SessionStatusEnumMap, json['status']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      lockedAt: json['lockedAt'] == null
          ? null
          : DateTime.parse(json['lockedAt'] as String),
      settledAt: json['settledAt'] == null
          ? null
          : DateTime.parse(json['settledAt'] as String),
      result: json['result'] as String?,
      isAdminOverride: json['isAdminOverride'] as bool? ?? false,
      totalOverBets: (json['totalOverBets'] as num?)?.toDouble() ?? 0.0,
      totalUnderBets: (json['totalUnderBets'] as num?)?.toDouble() ?? 0.0,
      oddsOver: (json['oddsOver'] as num?)?.toDouble() ?? 1.85,
      oddsUnder: (json['oddsUnder'] as num?)?.toDouble() ?? 1.95,
      overUnderLine: (json['overUnderLine'] as num?)?.toDouble() ?? 2.5,
    );

Map<String, dynamic> _$$BettingSessionModelImplToJson(
        _$BettingSessionModelImpl instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'sessionNumber': instance.sessionNumber,
      'status': _$SessionStatusEnumMap[instance.status]!,
      'startedAt': instance.startedAt.toIso8601String(),
      'lockedAt': instance.lockedAt?.toIso8601String(),
      'settledAt': instance.settledAt?.toIso8601String(),
      'result': instance.result,
      'isAdminOverride': instance.isAdminOverride,
      'totalOverBets': instance.totalOverBets,
      'totalUnderBets': instance.totalUnderBets,
      'oddsOver': instance.oddsOver,
      'oddsUnder': instance.oddsUnder,
      'overUnderLine': instance.overUnderLine,
    };

const _$SessionStatusEnumMap = {
  SessionStatus.open: 'open',
  SessionStatus.locked: 'locked',
  SessionStatus.settled: 'settled',
};
