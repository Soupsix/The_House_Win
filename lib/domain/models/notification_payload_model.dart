import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_payload_model.freezed.dart';
part 'notification_payload_model.g.dart';

@freezed
class NotificationPayloadModel with _$NotificationPayloadModel {
  const factory NotificationPayloadModel({
    required String type,
    String? route,
    String? referenceId,
    Map<String, dynamic>? extraData,
  }) = _NotificationPayloadModel;

  factory NotificationPayloadModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationPayloadModelFromJson(json);

  /// Helpers for parsing from String payload (Local Notification)
  factory NotificationPayloadModel.fromString(String? payloadString) {
    if (payloadString == null || payloadString.isEmpty) {
      return const NotificationPayloadModel(type: 'unknown');
    }
    try {
      final json = jsonDecode(payloadString) as Map<String, dynamic>;
      return NotificationPayloadModel.fromJson(json);
    } catch (e) {
      return const NotificationPayloadModel(type: 'unknown');
    }
  }
}
