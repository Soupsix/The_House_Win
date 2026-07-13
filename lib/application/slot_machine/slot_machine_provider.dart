import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/firebase/slot_machine_service.dart';
import '../../domain/repositories/i_slot_machine_repository.dart';
import 'slot_machine_notifier.dart';
import 'slot_machine_state.dart';

final slotMachineRepositoryProvider = Provider<ISlotMachineRepository>((ref) {
  return SlotMachineService();
});

final slotMachineProvider =
    StateNotifierProvider<SlotMachineNotifier, SlotMachineState>((ref) {
  return SlotMachineNotifier(ref.watch(slotMachineRepositoryProvider));
});
