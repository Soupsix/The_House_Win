// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationSettingsModelImpl _$$NotificationSettingsModelImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationSettingsModelImpl(
      upcomingMatch: json['upcomingMatch'] as bool? ?? true,
      betResults: json['betResults'] as bool? ?? true,
      walletLowBalance: json['walletLowBalance'] as bool? ?? true,
      adminAnnouncements: json['adminAnnouncements'] as bool? ?? true,
      educational: json['educational'] as bool? ?? true,
      antiGambling: json['antiGambling'] as bool? ?? true,
      dailyReminder: json['dailyReminder'] as bool? ?? true,
      weeklyReminder: json['weeklyReminder'] as bool? ?? true,
    );

Map<String, dynamic> _$$NotificationSettingsModelImplToJson(
        _$NotificationSettingsModelImpl instance) =>
    <String, dynamic>{
      'upcomingMatch': instance.upcomingMatch,
      'betResults': instance.betResults,
      'walletLowBalance': instance.walletLowBalance,
      'adminAnnouncements': instance.adminAnnouncements,
      'educational': instance.educational,
      'antiGambling': instance.antiGambling,
      'dailyReminder': instance.dailyReminder,
      'weeklyReminder': instance.weeklyReminder,
    };
