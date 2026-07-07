// Loại giao dịch ví ảo
enum TransactionType {
  // Khoá tiền khi đặt cược
  betLocked,
  // Cộng tiền khi thắng cược
  betWin,
  // Ghi nhận khi thua cược
  betLose,
  // Admin rút tiền
  adminWithdraw,
  // Reset ví về mặc định
  walletReset,
}
