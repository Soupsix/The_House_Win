// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationHistoryModelImpl _$$NotificationHistoryModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationHistoryModelImpl(
      id: (json['id'] as num?)?.toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as String,
      receivedAt: DateTime.parse(json['receivedAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
      payload: json['payload'] as String?,
    );

Map<String, dynamic> _$$NotificationHistoryModelImplToJson(
        _$NotificationHistoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'type': instance.type,
      'receivedAt': instance.receivedAt.toIso8601String(),
      'isRead': instance.isRead,
      'payload': instance.payload,
    };
