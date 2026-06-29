import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_notifier.dart';

final walletProvider = StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  return WalletNotifier();
});
