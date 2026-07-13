import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../../application/notification/notification_provider.dart';
import '../../core/services/notification_service.dart';

class NotificationTestScreen extends ConsumerWidget {
  const NotificationTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Tester'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (notifState.isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Text(
                'FCM Token:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Gap(8),
              SelectableText(
                notifState.fcmToken ?? 'Token not available',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const Gap(24),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.showNotification(
                  id: 1,
                  title: 'Test Local Notification',
                  body: 'This is a test notification generated locally.',
                  payload: jsonEncode({
                    'type': 'test',
                    'route': '/profile' // Example routing
                  }),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Show Local Notification'),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () {
                final scheduledTime = DateTime.now().add(const Duration(seconds: 15));
                NotificationService.scheduleNotification(
                  id: 2,
                  title: 'Scheduled Reminder',
                  body: 'This notification was scheduled 15 seconds ago!',
                  scheduledTime: scheduledTime,
                  payload: jsonEncode({
                    'type': 'reminder',
                    'route': '/wallet'
                  }),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Scheduled for 15s from now')),
                );
              },
              icon: const Icon(Icons.schedule),
              label: const Text('Schedule for 15s (Reminder)'),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.cancelNotification(2);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cancelled notification ID 2')),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Scheduled (ID: 2)'),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () {
                NotificationService.cancelAllNotifications();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cancelled all local notifications')),
                );
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Cancel All Local'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
