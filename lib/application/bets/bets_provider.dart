import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bets_notifier.dart';

final betsProvider = StateNotifierProvider<BetsNotifier, AsyncValue<void>>((ref) {
  return BetsNotifier();
});
