import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'matches_notifier.dart';

final matchesProvider = StateNotifierProvider<MatchesNotifier, AsyncValue<void>>((ref) {
  return MatchesNotifier();
});
