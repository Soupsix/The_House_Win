import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'anti_gambling_state.dart';
import '../../data/firebase/firestore_service.dart';

// Notifier quản lý các cảnh báo và hành vi hạn chế cờ bạc
class AntiGamblingNotifier extends StateNotifier<AntiGamblingState> {
  final FirestoreService _firestoreService;

  AntiGamblingNotifier(this._firestoreService) : super(const AntiGamblingState());

  // Xử lý khi phát hiện người chơi bị cháy túi (Số dư khả dụng dưới 10%)
  Future<void> onBrokeDetected(String uid) async {
    final nextBrokeCount = state.brokeCount + 1;
    state = state.copyWith(
      brokeCount: nextBrokeCount,
    );

    try {
      // Ghi số lần cháy túi vào Firestore
      await _firestoreService.incrementBrokeCount(uid);

      // Hiển thị nút bẫy vay vốn giả sau 3 giây delay để kích thích tâm lý
      await Future.delayed(const Duration(seconds: 3));
      
      // Kiểm tra nếu người chơi vẫn đang cháy túi (chưa reset ví)
      state = state.copyWith(showLoanTrap: true);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  // Xử lý khi người chơi nhấp vào nút bẫy vay vốn giả
  Future<void> onLoanTrapClicked(String uid) async {
    state = state.copyWith(
      loanTrapClickCount: state.loanTrapClickCount + 1,
      showWarningOverlay: true,
    );

    try {
      // Ghi nhận số lần click bẫy vay vốn vào Firestore
      await _firestoreService.incrementLoanTrapClickCount(uid);

      // Rung phản hồi xúc giác (Haptic Feedback) liên tục 3 lần để cảnh báo
      for (int i = 0; i < 3; i++) {
        await HapticFeedback.vibrate();
        await Future.delayed(const Duration(milliseconds: 200));
      }
    } catch (e) {
      // Bỏ qua lỗi rung thiết bị
    }
  }

  // Đóng màn hình đỏ cảnh báo và ẩn nút bẫy vay vốn
  void dismissWarning() {
    state = state.copyWith(
      showWarningOverlay: false,
      showLoanTrap: false,
    );
  }

  // Reset lại trạng thái cảnh báo khi người chơi reset lại ví ảo (giữ nguyên thống kê)
  void onWalletReset() {
    state = state.copyWith(
      showLoanTrap: false,
      showWarningOverlay: false,
    );
  }
}
