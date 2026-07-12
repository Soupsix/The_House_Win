import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../data/firebase/firestore_service.dart';
import '../../domain/models/transaction_model.dart';
import 'wallet_state.dart';

class WalletNotifier extends StateNotifier<WalletState> {
  final FirestoreService _firestoreService;

  StreamSubscription? _walletSubscription;

  WalletNotifier(this._firestoreService)
      : super(const WalletState());

  @override
  void dispose() {
    _walletSubscription?.cancel();
    super.dispose();
  }

  bool _calculateIsBroke(double balance, double lockedAmount) {
    final availableBalance = balance - lockedAmount;
    return availableBalance < AppConstants.brokeThreshold;
  }

  Future<void> _syncBrokeStatus(
      String uid,
      bool currentFirestoreStatus,
      bool calculatedStatus,
      ) async {
    if (currentFirestoreStatus == calculatedStatus) {
      return;
    }

    await _firestoreService.updateIsBrokeStatus(
      uid,
      calculatedStatus,
    );
  }

  Future<void> loadWallet(String uid) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final walletDoc =
      await _firestoreService.getWalletDocument(uid);

      double balance = AppConstants.initialBalance;
      double lockedAmount = 0;
      bool storedIsBroke = false;

      if (walletDoc.exists && walletDoc.data() != null) {
        final data = walletDoc.data()!;

        balance =
            (data['balance'] as num?)?.toDouble() ??
                AppConstants.initialBalance;

        lockedAmount =
            (data['lockedAmount'] as num?)?.toDouble() ??
                0;

        storedIsBroke =
            data['isBroke'] as bool? ?? false;
      } else {
        await _firestoreService.createWalletDocument(uid);
      }

      final calculatedIsBroke = _calculateIsBroke(
        balance,
        lockedAmount,
      );

      await _syncBrokeStatus(
        uid,
        storedIsBroke,
        calculatedIsBroke,
      );

      final transSnap =
      await _firestoreService.getTransactionsLimit20(uid);

      final transactionHistory = transSnap.docs
          .map(TransactionModel.fromFirestore)
          .toList();

      // Tính thống kê từ lịch sử giao dịch
      double totalBet = 0;
      double totalWon = 0;
      double totalLost = 0;
      for (final tx in transactionHistory) {
        if (tx.type == 'BET_PLACED' || tx.type == 'BET_LOCKED') {
          totalBet += tx.amount.abs();
        } else if (tx.type == 'BET_WIN' || tx.type == 'BET_PAYOUT') {
          totalWon += tx.amount;
        } else if (tx.type == 'BET_LOSE') {
          totalLost += tx.amount.abs();
        }
      }

      state = state.copyWith(
        balance: balance,
        lockedAmount: lockedAmount,
        isBroke: calculatedIsBroke,
        transactionHistory: transactionHistory,
        totalBet: totalBet,
        totalWon: totalWon,
        totalLost: totalLost,
        isLoading: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
        'Không thể tải thông tin ví ảo: $e',
      );
    }
  }

  Future<void> deductBet(
      String uid,
      double amount,
      String betId,
      ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _firestoreService.runDeductBetTransaction(
        uid: uid,
        amount: amount,
        betId: betId,
      );

      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Đặt cược thất bại: $e',
      );

      rethrow;
    }
  }

  Future<void> settleBet(
      String uid,
      double amount,
      double payout,
      String betId,
      bool isWin,
      ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _firestoreService.runSettleBetTransaction(
        uid: uid,
        amount: amount,
        payout: payout,
        betId: betId,
        isWin: isWin,
      );

      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
        'Giải quyết cược thất bại: $e',
      );
    }
  }

  Future<void> checkBrokeThreshold(String uid) async {
    final calculatedIsBroke = _calculateIsBroke(
      state.balance,
      state.lockedAmount,
    );

    if (calculatedIsBroke == state.isBroke) {
      return;
    }

    try {
      await _firestoreService.updateIsBrokeStatus(
        uid,
        calculatedIsBroke,
      );

      state = state.copyWith(
        isBroke: calculatedIsBroke,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage:
        'Lỗi khi cập nhật trạng thái cháy túi: $e',
      );
    }
  }

  Future<void> adminEditBalance(
      String uid,
      double newBalance,
      ) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _firestoreService
          .runAdminEditBalanceTransaction(
        uid: uid,
        newBalance: newBalance,
      );

      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
        'Chỉnh sửa số dư thất bại: $e',
      );
    }
  }

  Future<void> resetWallet(String uid) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _firestoreService
          .runResetWalletTransaction(uid);

      await loadWallet(uid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
        'Khởi động lại ví thất bại: $e',
      );
    }
  }

  // 2.7 - User yêu cầu rút tiền (gửi lên Firestore để Admin duyệt)
  Future<void> requestWithdrawal(String uid, double amount) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (amount > state.availableBalance) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Số tiền rút vượt quá số dư khả dụng',
        );
        return;
      }
      await _firestoreService.createWithdrawalRequest(
        uid: uid,
        amount: amount,
        method: 'Crypto Wallet',
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gửi yêu cầu thất bại: $e',
      );
    }
  }

  void watchWallet(String uid) {
    _walletSubscription?.cancel();

    _walletSubscription = _firestoreService
        .watchWalletDocument(uid)
        .listen(
          (doc) async {
        if (!doc.exists || doc.data() == null) {
          return;
        }

        final data = doc.data()!;

        final balance =
            (data['balance'] as num?)?.toDouble() ??
                0;

        final lockedAmount =
            (data['lockedAmount'] as num?)?.toDouble() ??
                0;

        final storedIsBroke =
            data['isBroke'] as bool? ?? false;

        final calculatedIsBroke = _calculateIsBroke(
          balance,
          lockedAmount,
        );

        state = state.copyWith(
          balance: balance,
          lockedAmount: lockedAmount,
          isBroke: calculatedIsBroke,
          isLoading: false,
          errorMessage: null,
        );

        try {
          await _syncBrokeStatus(
            uid,
            storedIsBroke,
            calculatedIsBroke,
          );
        } catch (e) {
          state = state.copyWith(
            errorMessage:
            'Không thể đồng bộ trạng thái số dư thấp: $e',
          );
        }
      },
      onError: (Object error) {
        state = state.copyWith(
          errorMessage:
          'Lỗi lắng nghe ví ảo realtime: $error',
        );
      },
    );
  }
}