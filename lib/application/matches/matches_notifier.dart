import 'package:flutter_riverpod/flutter_riverpod.dart';

class MatchesNotifier extends StateNotifier<AsyncValue<void>> {
  MatchesNotifier() : super(const AsyncValue.data(null));
}
