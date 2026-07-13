// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_payload_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationPayloadModelImpl _$$NotificationPayloadModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationPayloadModelImpl(
      type: json['type'] as String,
      route: json['route'] as String?,
      referenceId: json['referenceId'] as String?,
      extraData: json['extraData'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$NotificationPayloadModelImplToJson(
        _$NotificationPayloadModelImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'route': instance.route,
      'referenceId': instance.referenceId,
      'extraData': instance.extraData,
    };
