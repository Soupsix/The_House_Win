import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_history_model.freezed.dart';
part 'notification_history_model.g.dart';

@freezed
class NotificationHistoryModel with _$NotificationHistoryModel {
  const factory NotificationHistoryModel({
    int? id, // SQLite primary key
    required String title,
    required String body,
    required String type,
    required DateTime receivedAt,
    @Default(false) bool isRead,
    String? payload,
  }) = _NotificationHistoryModel;

  factory NotificationHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationHistoryModelFromJson(json);
}
