import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'anti_gambling_state.dart';
import 'anti_gambling_notifier.dart';
import '../wallet/wallet_provider.dart'; // import firestoreServiceProvider, isBrokeProvider
import '../auth/auth_provider.dart';   // import currentUserProvider

// Provider cho AntiGamblingNotifier
final antiGamblingProvider = StateNotifierProvider<AntiGamblingNotifier, AntiGamblingState>(
  (ref) {
    final notifier = AntiGamblingNotifier(ref.read(firestoreServiceProvider));

    // Lắng nghe isBrokeProvider — tự động trigger khi wallet cháy túi
    ref.listen<bool>(isBrokeProvider, (previous, next) {
      if (next == true && (previous == null || previous == false)) {
        final user = ref.read(currentUserProvider);
        if (user != null) {
          notifier.onBrokeDetected(user.uid);
        }
      }
    });

    return notifier;
  },
);

// Convenience providers cho các module khác dùng
// Chỉ rebuild khi đúng field đó thay đổi — không watch toàn bộ antiGamblingProvider

// Provider lấy trạng thái hiển thị bẫy vay vốn giả
final showLoanTrapProvider = Provider<bool>(
  (ref) => ref.watch(antiGamblingProvider.select((s) => s.showLoanTrap)),
);

// Provider lấy trạng thái hiển thị màn đỏ cảnh báo khẩn cấp
final showWarningOverlayProvider = Provider<bool>(
  (ref) => ref.watch(antiGamblingProvider.select((s) => s.showWarningOverlay)),
);
