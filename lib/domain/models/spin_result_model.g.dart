// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spin_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SpinResultModelImpl _$$SpinResultModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SpinResultModelImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      betAmount: (json['betAmount'] as num).toDouble(),
      segmentId: json['segmentId'] as String,
      multiplier: (json['multiplier'] as num).toDouble(),
      payout: (json['payout'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      transactionId: json['transactionId'] as String?,
    );

Map<String, dynamic> _$$SpinResultModelImplToJson(
        _$SpinResultModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'betAmount': instance.betAmount,
      'segmentId': instance.segmentId,
      'multiplier': instance.multiplier,
      'payout': instance.payout,
      'createdAt': instance.createdAt.toIso8601String(),
      'transactionId': instance.transactionId,
    };
