import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../../domain/models/match_model.dart';
import '../../auth/auth_provider.dart';
import 'dart:math';

class ReminderManager {
  // Feature 1: Upcoming Match Reminder
  static Future<void> scheduleMatchReminder({
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required DateTime startTime,
    required bool isEnabled,
  }) async {
    if (!isEnabled) return;

    // Check if match is in the future
    if (startTime.isBefore(DateTime.now())) return;

    // Schedule for 15 mins before
    final scheduleTime = startTime.subtract(const Duration(minutes: 15));
    if (scheduleTime.isBefore(DateTime.now())) return;

    // ID derived from match hash to allow cancellation
    final notificationId = matchId.hashCode;

    await NotificationService.scheduleNotification(
      id: notificationId,
      title: '⚽ Match Starting Soon',
      body: '$homeTeam vs $awayTeam starts in 15 minutes!',
      scheduledTime: scheduleTime,
      payload: jsonEncode({
        'type': 'match_reminder',
        'matchId': matchId,
        'route': '/matches/detail/$matchId',
      }),
    );
  }

  static Future<void> cancelMatchReminder(MatchModel match) async {
    await NotificationService.cancelNotification(match.id.hashCode);
  }

  // Feature 5 & 6: Daily & Inactive Reminders
  static Future<void> scheduleInactivityReminders(WidgetRef ref) async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final settings = user.notificationSettings;

    // Cancel existing inactivity reminders to reset the timer
    await NotificationService.cancelNotification(200); // Daily
    await NotificationService.cancelNotification(201); // 3 days
    await NotificationService.cancelNotification(202); // 7 days

    if (settings.dailyReminder) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dailyTime = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0); // 9 AM tomorrow
      
      await NotificationService.scheduleNotification(
        id: 200,
        title: '👋 Ready for today\'s matches?',
        body: 'Come back and make your predictions.',
        scheduledTime: dailyTime,
        payload: jsonEncode({'type': 'daily_reminder'}),
      );
    }

    // Inactivity 3 days
    final threeDays = DateTime.now().add(const Duration(days: 3));
    await NotificationService.scheduleNotification(
      id: 201,
      title: 'We miss you!',
      body: 'Your virtual wallet is waiting. Come place some bets!',
      scheduledTime: threeDays,
      payload: jsonEncode({'type': 'inactivity_reminder'}),
    );

    // Inactivity 7 days
    final sevenDays = DateTime.now().add(const Duration(days: 7));
    await NotificationService.scheduleNotification(
      id: 202,
      title: 'It\'s been a while...',
      body: 'Check out the new matches and features in Betwise.',
      scheduledTime: sevenDays,
      payload: jsonEncode({'type': 'inactivity_reminder'}),
    );
  }

  // Feature 12: Educational Notification
  static Future<void> scheduleEducationalNotification(WidgetRef ref) async {
    final user = ref.read(authProvider).user;
    if (user == null || !user.notificationSettings.educational) return;

    await NotificationService.cancelNotification(300);

    final facts = [
      'Expected Value matters more than luck.',
      'Avoid Gambler\'s Fallacy. Past results don\'t guarantee future ones.',
      'Bankroll management is key to long-term success.',
    ];
    
    final randomFact = facts[Random().nextInt(facts.length)];
    // Schedule randomly between 2 to 4 hours from now
    final hours = 2 + Random().nextInt(3);
    final scheduleTime = DateTime.now().add(Duration(hours: hours));

    await NotificationService.scheduleNotification(
      id: 300,
      title: '💡 Did you know?',
      body: randomFact,
      scheduledTime: scheduleTime,
      payload: jsonEncode({'type': 'educational', 'route': '/education'}),
    );
  }

  // Feature 13: Weekly Statistics
  static Future<void> scheduleWeeklyStatistics(WidgetRef ref) async {
    final user = ref.read(authProvider).user;
    if (user == null || !user.notificationSettings.weeklyReminder) return;

    await NotificationService.cancelNotification(400);

    // Calculate next Sunday at 6 PM
    var now = DateTime.now();
    var daysUntilSunday = DateTime.sunday - now.weekday;
    if (daysUntilSunday < 0) daysUntilSunday += 7;
    
    var nextSunday = now.add(Duration(days: daysUntilSunday));
    var scheduleTime = DateTime(nextSunday.year, nextSunday.month, nextSunday.day, 18, 0);
    
    if (scheduleTime.isBefore(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 7));
    }

    await NotificationService.scheduleNotification(
      id: 400,
      title: '📊 This Week Summary',
      body: 'Check your betting statistics for this week.',
      scheduledTime: scheduleTime,
      payload: jsonEncode({'type': 'weekly_stats', 'route': '/profile'}), // Navigate to profile/stats
    );
  }
}
