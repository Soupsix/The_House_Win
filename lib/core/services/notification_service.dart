import 'dart:async';
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../data/local/notification_history_db.dart';
import '../../domain/models/notification_history_model.dart';
import '../../domain/models/notification_payload_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream để App lắng nghe khi user tap vào notification lúc app đang chạy ngầm hoặc mở
  static final StreamController<String?> onNotificationClick =
      StreamController<String?>.broadcast();

  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        onNotificationClick.add(response.payload);
      },
    );
  }

  static Future<void> requestPermission() async {
    final androidImplementation = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
    // iOS permission is handled in DarwinInitializationSettings or FCM
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final parsedPayload = NotificationPayloadModel.fromString(payload);
    
    // Check for duplicate (within 1 hour for the same title/type), skip if type is 'unknown'
    if (parsedPayload.type != 'unknown') {
      final isDuplicate = await NotificationHistoryDatabase.instance.isDuplicate(
        parsedPayload.type,
        title,
        const Duration(hours: 1),
      );

      if (isDuplicate) return;
    } // Prevent duplicate

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'betwise_main_channel',
      'Betwise Notifications',
      channelDescription: 'Main notification channel for Betwise',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );

    // Save to history
    await NotificationHistoryDatabase.instance.create(
      NotificationHistoryModel(
        title: title,
        body: body,
        type: parsedPayload.type,
        receivedAt: DateTime.now(),
        payload: payload,
      ),
    );
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'betwise_schedule_channel',
      'Betwise Reminders',
      channelDescription: 'Scheduled reminders for Betwise',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
