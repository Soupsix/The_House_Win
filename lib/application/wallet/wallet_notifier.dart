import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'wallet_state.dart';
import '../../data/firebase/firestore_service.dart';
import '../../domain/models/transaction_model.dart';
import '../../core/constants/app_constants.dart';

// Notifier quản lý trạng thái ví ảo và các giao dịch tài chính
class WalletNotifier extends StateNotifier<WalletState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _walletSubscription;

  WalletNotifier(this._firestoreService) : super(const WalletState());

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }

  // Tải thông tin ví ảo và lịch sử giao dịch gần đây của người dùng
  Future<void> loadWallet(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Đọc document wallets/{uid} từ Firestore
      final walletDoc = await _firestoreService.getWalletDocument(uid);
      
      double balance = AppConstants.initialBalance;
      double lockedAmount = 0.0;
      bool isBroke = false;

      if (walletDoc.exists) {
        final data = walletDoc.data()!;
        balance = (data['balance'] as num?)?.toDouble() ?? balance;
        lockedAmount = (data['lockedAmount'] as num?)?.toDouble() ?? lockedAmount;
        isBroke = data['isBroke'] as bool? ?? isBroke;
      } else {
        // Tạo ví mới nếu chưa tồn tại
        await _firestoreService.createWalletDocument(uid);
      }

      // Đọc thêm 20 transaction gần nhất từ collection transactions
      final transSnap = await _firestoreService.getTransactionsLimit20(uid);
      final transactionHistory = transSnap.docs.map((doc) {
        return TransactionModel.fromFirestore(doc);
      }).toList();

      state = state.copyWith(
        balance: balance,
        lockedAmount: lockedAmount,
        isBroke: isBroke,
        transactionHistory: transactionHistory,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Không thể tải thông tin ví ảo: $e',
      );
    }
  }

  // Khấu trừ tiền cược từ ví (Deduct Bet)
  Future<void> deductBet(String uid, double amount, String betId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Sử dụng Firestore transaction để tránh race condition
      await _firestoreService.runDeductBetTransaction(
        uid: uid,
        amount: amount,
        betId: betId,
      );

      // Tải lại ví để đồng bộ state
      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Đặt cược thất bại: $e',
      );
      rethrow;
    }
  }

  // Giải quyết kết quả cược và cập nhật số dư ví ảo (Settle Bet)
  Future<void> settleBet(
    String uid,
    double amount,
    double payout,
    String betId,
    bool isWin,
  ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreService.runSettleBetTransaction(
        uid: uid,
        amount: amount,
        payout: payout,
        betId: betId,
        isWin: isWin,
      );

      // Đồng bộ lại ví
      await loadWallet(uid);

      // Kiểm tra ngưỡng cháy túi
      await checkBrokeThreshold(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Giải quyết cược thất bại: $e',
      );
    }
  }

  // Kiểm tra ngưỡng cháy túi để kích hoạt tính năng Anti-Gambling
  Future<void> checkBrokeThreshold(String uid) async {
    // So sánh balanceRatio với AppConstants.brokeThreshold (10%)
    if (state.balanceRatio <= AppConstants.brokeThreshold) {
      try {
        await _firestoreService.updateIsBrokeStatus(uid, true);
        state = state.copyWith(isBroke: true);
      } catch (e) {
        state = state.copyWith(
          errorMessage: 'Lỗi khi cập nhật trạng thái cháy túi: $e',
        );
      }
    }
  }

  // Admin thực hiện chỉnh sửa số dư ví của người chơi
  Future<void> adminEditBalance(String uid, double newBalance) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreService.runAdminEditBalanceTransaction(
        uid: uid,
        newBalance: newBalance,
      );
      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Chỉnh sửa số dư thất bại: $e',
      );
    }
  }

  // Khởi động lại ví ảo về trạng thái mặc định ban đầu và xóa lịch sử giao dịch
  Future<void> resetWallet(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _firestoreService.runResetWalletTransaction(uid);
      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Khởi động lại ví thất bại: $e',
      );
    }
  }

  // Lắng nghe realtime các thay đổi ví của người chơi từ Firestore
  void watchWallet(String uid) {
    _walletSubscription?.cancel();
    _walletSubscription = _firestoreService.watchWalletDocument(uid).listen(
      (doc) {
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
          final lockedAmount = (data['lockedAmount'] as num?)?.toDouble() ?? 0.0;
          final isBroke = data['isBroke'] as bool? ?? false;

          state = state.copyWith(
            balance: balance,
            lockedAmount: lockedAmount,
            isBroke: isBroke,
          );
        }
      },
      onError: (e) {
        state = state.copyWith(
          errorMessage: 'Lỗi lắng nghe ví ảo realtime: $e',
        );
      },
    );
  }
}
