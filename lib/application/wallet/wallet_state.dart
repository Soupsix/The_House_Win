import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/transaction_model.dart';
import '../../core/constants/app_constants.dart';

part 'wallet_state.freezed.dart';

// State đại diện cho Ví ảo
@freezed
class WalletState with _$WalletState {
  const factory WalletState({
    @Default(0) double balance,
    @Default(0) double lockedAmount,
    @Default(false) bool isBroke,
    @Default(false) bool isLoading,
    @Default([]) List<TransactionModel> transactionHistory,
    @Default(0) double totalBet,
    @Default(0) double totalWon,
    @Default(0) double totalLost,
    String? errorMessage,
  }) = _WalletState;
}

// Computed getter — Số dư thực tế khả dụng sau khi trừ tiền đang khoá
// Đặt trong extension riêng vì Freezed không hỗ trợ getter trực tiếp
extension WalletStateX on WalletState {
  // Số dư thực tế khả dụng
  double get availableBalance => balance - lockedAmount;

  // Tỷ lệ % còn lại so với vốn ban đầu — dùng để check ngưỡng cháy túi
  double get balanceRatio => balance / AppConstants.initialBalance;
}
