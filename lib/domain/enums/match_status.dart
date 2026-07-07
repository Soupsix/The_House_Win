// Trạng thái trận đấu bóng đá
enum MatchStatus {
  // Chưa bắt đầu
  scheduled,
  // Đang diễn ra
  inPlay,
  // Đã kết thúc
  finished,
}

// Kết quả của trận đấu theo kèo tài xỉu
enum MatchResult {
  // Kết quả ra Tài
  over,
  // Kết quả ra Xỉu
  under,
  // Kết quả Hoà (hoàn tiền)
  push,
}
