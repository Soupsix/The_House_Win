import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/notification/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final settings = user.notificationSettings;
    final notifier = ref.read(notificationProvider.notifier);

    void updateSetting(String key, bool value) {
      final json = settings.toJson();
      json[key] = value;
      notifier.updateSettings(json);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Upcoming Match Reminders'),
            subtitle: const Text('Notify me 15 minutes before a match starts'),
            value: settings.upcomingMatch,
            onChanged: (v) => updateSetting('upcomingMatch', v),
          ),
          SwitchListTile(
            title: const Text('Bet Results'),
            subtitle: const Text('Notify me when my bets are settled'),
            value: settings.betResults,
            onChanged: (v) => updateSetting('betResults', v),
          ),
          SwitchListTile(
            title: const Text('Wallet Low Balance'),
            subtitle: const Text('Warn me when my balance is low'),
            value: settings.walletLowBalance,
            onChanged: (v) => updateSetting('walletLowBalance', v),
          ),
          SwitchListTile(
            title: const Text('Admin Announcements'),
            subtitle: const Text('Important news from the admins'),
            value: settings.adminAnnouncements,
            onChanged: (v) => updateSetting('adminAnnouncements', v),
          ),
          SwitchListTile(
            title: const Text('Educational Facts'),
            subtitle: const Text('Random tips and facts about probability'),
            value: settings.educational,
            onChanged: (v) => updateSetting('educational', v),
          ),
          SwitchListTile(
            title: const Text('Anti-Gambling Warnings'),
            subtitle: const Text('Alerts if you are losing consecutively'),
            value: settings.antiGambling,
            onChanged: (v) => updateSetting('antiGambling', v),
          ),
          SwitchListTile(
            title: const Text('Daily Reminders'),
            subtitle: const Text('Morning reminders to check matches'),
            value: settings.dailyReminder,
            onChanged: (v) => updateSetting('dailyReminder', v),
          ),
          SwitchListTile(
            title: const Text('Weekly Statistics'),
            subtitle: const Text('Summary of your betting week on Sunday'),
            value: settings.weeklyReminder,
            onChanged: (v) => updateSetting('weeklyReminder', v),
          ),
        ],
      ),
    );
  }
}
