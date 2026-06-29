import 'package:flutter_riverpod/flutter_riverpod.dart';

class BetsNotifier extends StateNotifier<AsyncValue<void>> {
  BetsNotifier() : super(const AsyncValue.data(null));
}
