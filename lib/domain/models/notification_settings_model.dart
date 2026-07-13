import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_settings_model.freezed.dart';
part 'notification_settings_model.g.dart';

@freezed
class NotificationSettingsModel with _$NotificationSettingsModel {
  const factory NotificationSettingsModel({
    @Default(true) bool upcomingMatch,
    @Default(true) bool betResults,
    @Default(true) bool walletLowBalance,
    @Default(true) bool adminAnnouncements,
    @Default(true) bool educational,
    @Default(true) bool antiGambling,
    @Default(true) bool dailyReminder,
    @Default(true) bool weeklyReminder,
  }) = _NotificationSettingsModel;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);
}
