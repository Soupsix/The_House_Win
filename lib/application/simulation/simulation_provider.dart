import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simulation_state.dart';
import 'simulation_notifier.dart';
import '../wallet/wallet_provider.dart'; // import firestoreServiceProvider

// Provider cho SimulationNotifier
final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>(
  (ref) => SimulationNotifier(ref.read(firestoreServiceProvider)),
);
