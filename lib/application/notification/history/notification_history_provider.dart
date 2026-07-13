import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/notification_history_db.dart';
import 'notification_history_state.dart';

final notificationHistoryProvider =
    StateNotifierProvider<NotificationHistoryNotifier, NotificationHistoryState>((ref) {
  return NotificationHistoryNotifier();
});

class NotificationHistoryNotifier extends StateNotifier<NotificationHistoryState> {
  NotificationHistoryNotifier() : super(const NotificationHistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final notifications = await NotificationHistoryDatabase.instance.readAllNotifications();
      state = state.copyWith(
        isLoading: false,
        notifications: notifications,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await NotificationHistoryDatabase.instance.markAsRead(id);
      // Reload or update local list
      final updatedList = state.notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();
      
      state = state.copyWith(notifications: updatedList);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> delete(int id) async {
    try {
      await NotificationHistoryDatabase.instance.delete(id);
      final updatedList = state.notifications.where((n) => n.id != id).toList();
      state = state.copyWith(notifications: updatedList);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> clearAll() async {
    try {
      await NotificationHistoryDatabase.instance.clearAll();
      state = state.copyWith(notifications: []);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}
