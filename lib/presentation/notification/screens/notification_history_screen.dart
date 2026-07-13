import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../application/notification/history/notification_history_provider.dart';

class NotificationHistoryScreen extends ConsumerWidget {
  const NotificationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(notificationHistoryProvider);
    final historyNotifier = ref.read(notificationHistoryProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/notification-settings');
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              historyNotifier.clearAll();
            },
          ),
        ],
      ),
      body: historyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : historyState.notifications.isEmpty
              ? const Center(child: Text('No notifications yet.'))
              : ListView.builder(
                  itemCount: historyState.notifications.length,
                  itemBuilder: (context, index) {
                    final notif = historyState.notifications[index];
                    return Dismissible(
                      key: Key('notif_${notif.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16.0),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        if (notif.id != null) {
                          historyNotifier.delete(notif.id!);
                        }
                      },
                      child: ListTile(
                        leading: _getIconForType(notif.type),
                        title: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notif.body),
                            Text(
                              DateFormat('MMM d, h:mm a').format(notif.receivedAt),
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        tileColor: notif.isRead ? null : Colors.blue.withOpacity(0.1),
                        onTap: () {
                          if (notif.id != null) {
                            historyNotifier.markAsRead(notif.id!);
                          }
                          // Extract route from payload if it exists
                          // In a real app we would parse jsonEncode(payload) and navigate
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Widget _getIconForType(String type) {
    switch (type) {
      case 'match_reminder':
        return const Icon(Icons.sports_soccer, color: Colors.green);
      case 'wallet_low_balance':
      case 'anti_gambling':
        return const Icon(Icons.warning, color: Colors.orange);
      case 'jackpot':
        return const Icon(Icons.monetization_on, color: Colors.yellow);
      case 'educational':
        return const Icon(Icons.lightbulb, color: Colors.blue);
      default:
        return const Icon(Icons.notifications);
    }
  }
}
