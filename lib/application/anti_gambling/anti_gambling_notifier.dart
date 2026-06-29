import 'package:flutter_riverpod/flutter_riverpod.dart';

class AntiGamblingNotifier extends StateNotifier<AsyncValue<void>> {
  AntiGamblingNotifier() : super(const AsyncValue.data(null));
}
