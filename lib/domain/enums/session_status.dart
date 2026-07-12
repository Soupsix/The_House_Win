// Enum mô tả trạng thái của một phiên cược Tài Xỉu
enum SessionStatus {
  /// Phiên đang mở — người chơi được phép đặt cược (0–50 giây)
  open,

  /// Phiên đang khoá — không nhận thêm cược (50–60 giây)
  locked,

  /// Phiên đã kết thúc — kết quả đã được sinh ra
  settled,
}
