import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_state.dart';
import 'wallet_notifier.dart';
import '../../data/firebase/firestore_service.dart';

// Provider cho FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

// Provider cho WalletNotifier
final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) => WalletNotifier(ref.read(firestoreServiceProvider)),
);

// Convenience providers cho các module khác dùng
// Chỉ rebuild khi đúng field đó thay đổi — không watch toàn bộ walletProvider

// Provider lấy số dư tổng ví ảo hiện tại
final currentBalanceProvider = Provider<double>(
  (ref) => ref.watch(walletProvider.select((s) => s.balance)),
);

// Provider lấy số dư thực tế khả dụng sau khi trừ đi số tiền cược đang khoá
final availableBalanceProvider = Provider<double>(
  (ref) => ref.watch(walletProvider.select((s) => s.availableBalance)),
);

// Provider kiểm tra trạng thái cháy túi của người dùng
final isBrokeProvider = Provider<bool>(
  (ref) => ref.watch(walletProvider.select((s) => s.isBroke)),
);

// Provider lấy số tiền đang bị khoá trong các cược chưa thanh toán
final lockedAmountProvider = Provider<double>(
  (ref) => ref.watch(walletProvider.select((s) => s.lockedAmount)),
);
