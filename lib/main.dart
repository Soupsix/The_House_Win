import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'firebase_options.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

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
  @override
  void initState() {
    super.initState();
    // Khởi động timer service của phiên cược Tài Xỉu
    ref.read(diceTimerServiceProvider).start();
  }

  @override
  void dispose() {
    // Dừng timer khi đóng app
    ref.read(diceTimerServiceProvider).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'The House Wins',
      theme: AppTheme.dark,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}