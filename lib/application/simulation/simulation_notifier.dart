import 'package:flutter_riverpod/flutter_riverpod.dart';

class SimulationNotifier extends StateNotifier<AsyncValue<void>> {
  SimulationNotifier() : super(const AsyncValue.data(null));
}
