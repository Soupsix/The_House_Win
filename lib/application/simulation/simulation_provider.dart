import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simulation_notifier.dart';

final simulationProvider = StateNotifierProvider<SimulationNotifier, AsyncValue<void>>((ref) {
  return SimulationNotifier();
});
