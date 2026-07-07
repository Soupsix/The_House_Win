// Trạng thái của một cược đặt
enum BetStatus {
  // Đang chờ trận đấu kết thúc
  pending,
  // Thắng cược
  won,
  // Thua cược
  lost,
  // Hoàn tiền cược (hoà kèo)
  push,
}
