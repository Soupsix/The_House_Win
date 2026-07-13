import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

/// Top-level function to handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized if you need to use other Firebase services here.
  // In our case, we just rely on FCM's built-in system tray notification for background.
  // We can also trigger a local notification here if we wanted to customize it, 
  // but Android does it automatically for 'notification' payload.
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
  }
}

class FirebaseMessagingService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // Set background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      // If `message.notification` is not null, FCM doesn't automatically show it in foreground on Android.
      // We must show it manually using flutter_local_notifications.
      if (message.notification != null) {
        // Convert data to JSON string for local payload
        final payloadString = jsonEncode(message.data);
        
        NotificationService.showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'Thông báo',
          body: message.notification!.body ?? '',
          payload: payloadString,
        );
      }
    });

    // Listen for when the user taps on a notification in the system tray 
    // while the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      final payloadString = jsonEncode(message.data);
      NotificationService.onNotificationClick.add(payloadString);
    });
  }

  static Future<String?> getToken() async {
    try {
      return await _fcm.getToken();
    } catch (e) {
      if (kDebugMode) print('Error getting FCM token: $e');
      return null;
    }
  }

  static Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;

  // Handles notification tap when the app was completely terminated
  static Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      // Defer adding to the stream to allow the app to fully boot up
      // Or we can handle it at the routing layer directly.
      Future.delayed(const Duration(milliseconds: 500), () {
        final payloadString = jsonEncode(initialMessage.data);
        NotificationService.onNotificationClick.add(payloadString);
      });
    }
  }
}
