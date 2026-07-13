import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_slot_machine_repository.dart';
import 'slot_machine_state.dart';

class SlotMachineNotifier extends StateNotifier<SlotMachineState> {
  final ISlotMachineRepository _repository;

  SlotMachineNotifier(this._repository) : super(const SlotMachineState());

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final config = await _repository.getActiveConfig();
      state = state.copyWith(
        config: config,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải cấu hình Slot Machine: $e',
      );
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      final history = await _repository.getUserSlotHistory(userId);
      state = state.copyWith(history: history);
    } catch (e) {
      // Ignore error to not interrupt UI
    }
  }

  Future<void> pull(String userId, double betAmount) async {
    if (state.isSpinning) return;

    state = state.copyWith(
      isSpinning: true,
      lastResult: null,
      errorMessage: null,
    );

    try {
      final result = await _repository.pull(
        userId: userId,
        betAmount: betAmount,
      );

      // We don't add to history immediately because the animation needs to play
      state = state.copyWith(
        lastResult: result,
      );
    } catch (e) {
      state = state.copyWith(
        isSpinning: false,
        errorMessage: 'Lỗi khi quay: $e',
      );
    }
  }

  void onAnimationComplete() {
    if (state.lastResult != null) {
      // Add result to history after animation finishes
      final newHistory = [state.lastResult!, ...state.history];
      if (newHistory.length > 50) {
        newHistory.removeLast();
      }

      state = state.copyWith(
        isSpinning: false,
        history: newHistory,
      );
    } else {
      state = state.copyWith(isSpinning: false);
    }
  }

  void resetError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
