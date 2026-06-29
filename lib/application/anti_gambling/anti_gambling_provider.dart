import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'anti_gambling_notifier.dart';

final antiGamblingProvider = StateNotifierProvider<AntiGamblingNotifier, AsyncValue<void>>((ref) {
  return AntiGamblingNotifier();
});
