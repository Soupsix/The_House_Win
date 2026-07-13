import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/notification_service.dart';
import '../../wallet/wallet_provider.dart';
import '../../wallet/wallet_state.dart';
import '../../auth/auth_provider.dart';

final walletObserverProvider = Provider<void>((ref) {
  // Listen to changes in WalletState
  ref.listen<WalletState>(walletProvider, (previous, current) {
    if (previous == null) return;
    
    final user = ref.read(authProvider).user;
    if (user == null) return;
    
    final settings = user.notificationSettings;

    // Feature: Low Balance Warning
    if (settings.walletLowBalance) {
      if (previous.balance >= 1000 && current.balance < 1000) {
        // Trigger low balance notification
        NotificationService.showNotification(
          id: 100, // Unique ID for low balance
          title: '⚠ Low Balance',
          body: 'Your wallet balance has dropped below 1000 Coins.',
          payload: jsonEncode({
            'type': 'wallet_low_balance',
            'route': '/wallet' // Navigate to wallet
          }),
        );
      }
    }

    // Feature: Jackpot
    // Example: If user hits 1,000,000 coins from below 1M
    if (previous.balance < 1000000 && current.balance >= 1000000) {
      NotificationService.showNotification(
        id: 101, // Unique ID for jackpot
        title: '🎉 JACKPOT!',
        body: 'You have reached 1,000,000 Coins!',
        payload: jsonEncode({
          'type': 'jackpot',
          'route': '/wallet'
        }),
      );
    }
  });
});
