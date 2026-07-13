import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../anti_gambling/anti_gambling_provider.dart';
import '../../anti_gambling/anti_gambling_state.dart';
import '../../auth/auth_provider.dart';

final antiGamblingObserverProvider = Provider<void>((ref) {
  // Listen to changes in AntiGamblingState
  ref.listen<AntiGamblingState>(antiGamblingProvider, (previous, current) {
    if (previous == null) return;
    
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    final settings = user.notificationSettings;

    if (settings.antiGambling) {
      // Check for broke count
      if (current.brokeCount > previous.brokeCount) {
        NotificationService.showNotification(
          id: 102,
          title: 'Take a break?',
          body: 'You have gone broke ${current.brokeCount} times. Remember this is just a simulation.',
          payload: jsonEncode({
            'type': 'anti_gambling',
            'route': '/anti-gambling' 
          }),
        );
      }

      // Check for loan trap clicks
      if (current.loanTrapClickCount > previous.loanTrapClickCount) {
        NotificationService.showNotification(
          id: 103,
          title: 'Caution!',
          body: 'Borrowing money for gambling is dangerous.',
          payload: jsonEncode({
            'type': 'anti_gambling',
            'route': '/anti-gambling' 
          }),
        );
      }
    }
  });
});
