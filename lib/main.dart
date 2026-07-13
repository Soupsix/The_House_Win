import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/firebase_messaging_service.dart';
import 'domain/models/notification_payload_model.dart';
import 'data/local/notification_history_db.dart';
import 'application/notification/observers/wallet_observer.dart';
import 'application/notification/observers/anti_gambling_observer.dart';
import 'application/notification/managers/reminder_manager.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'application/bets/bet_provider.dart';
import 'application/bets/dice_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Firebase~/.pub-cache/bin/flutterfire configure -p the-win-house -y
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Timezone cho notification
  tz.initializeTimeZones();

  // Notification service
  await NotificationService.init();

  // Khởi tạo Database cho lịch sử thông báo
  await NotificationHistoryDatabase.instance.database;

  runApp(
    const ProviderScope(
      child: TheHouseWinsApp(),
    ),
  );
}

class TheHouseWinsApp extends ConsumerStatefulWidget {
  const TheHouseWinsApp({super.key});

  @override
  ConsumerState<TheHouseWinsApp> createState() => _TheHouseWinsAppState();
}

class _TheHouseWinsAppState extends ConsumerState<TheHouseWinsApp> {
  StreamSubscription<String?>? _notificationSub;

  @override
  void initState() {
    super.initState();
    // Khởi động timer service của phiên cược Tài Xỉu
    ref.read(diceTimerServiceProvider).start();

    // Khởi tạo FCM
    FirebaseMessagingService.init();

    // Setup listener for notification taps
    _notificationSub = NotificationService.onNotificationClick.stream.listen((payload) {
      if (payload != null) {
         final model = NotificationPayloadModel.fromString(payload);
         if (model.route != null && model.route!.isNotEmpty) {
            ref.read(routerProvider).push(model.route!);
         }
      }
    });

    // Check for messages that opened the app from terminated state
    FirebaseMessagingService.setupInteractedMessage();

    // Schedule Inactivity and Daily reminders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReminderManager.scheduleInactivityReminders(ref);
      ReminderManager.scheduleWeeklyStatistics(ref);
      ReminderManager.scheduleEducationalNotification(ref);
    });
  }

  @override
  void dispose() {
    _notificationSub?.cancel();
    // Dừng timer khi đóng app
    ref.read(diceTimerServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Watch global observers here so they stay alive and react to state changes
    ref.watch(walletObserverProvider);
    ref.watch(antiGamblingObserverProvider);

    return MaterialApp.router(
      title: 'The House Wins',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}