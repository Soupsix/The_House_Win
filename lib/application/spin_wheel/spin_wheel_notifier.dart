import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/i_spin_wheel_repository.dart';
import 'spin_wheel_state.dart';

class SpinWheelNotifier extends StateNotifier<SpinWheelState> {
  final ISpinWheelRepository _repository;

  SpinWheelNotifier(this._repository) : super(const SpinWheelState());

  Future<void> loadConfig() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final config = await _repository.getActiveConfig();
      state = state.copyWith(
        config: config,
        isLoading: false,
        betAmount: config?.minBet ?? 10000.0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải cấu hình vòng quay: $e',
      );
    }
  }

  Future<void> loadHistory(String userId) async {
    try {
      final history = await _repository.getUserSpinHistory(userId);
      state = state.copyWith(history: history);
    } catch (e) {
      // ignore
    }
  }

  void setBetAmount(double amount) {
    if (state.config == null) return;
    final minBet = state.config!.minBet;
    final maxBet = state.config!.maxBet;
    
    double newAmount = amount;
    if (newAmount < minBet) newAmount = minBet;
    if (newAmount > maxBet) newAmount = maxBet;
    
    state = state.copyWith(betAmount: newAmount);
  }

  Future<void> spin(String userId) async {
    if (state.isSpinning || state.config == null) return;
    
    state = state.copyWith(isSpinning: true, errorMessage: null);
    
    try {
      final result = await _repository.spin(
        userId: userId,
        betAmount: state.betAmount,
      );
      
      // Update state with result, keep isSpinning true until UI animation finishes
      // Chỉ cập nhật lastResult để trigger animation, CHƯA đưa vào lịch sử
      state = state.copyWith(
        lastResult: result,
      );
      
    } catch (e) {
      state = state.copyWith(
        isSpinning: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void onAnimationComplete() {
    if (state.lastResult != null) {
      state = state.copyWith(
        isSpinning: false,
        history: [state.lastResult!, ...state.history],
      );
    } else {
      state = state.copyWith(isSpinning: false);
    }
  }
}
