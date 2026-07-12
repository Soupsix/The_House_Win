// Các hằng số cấu hình hệ thống
class AppConstants {
  AppConstants._();

  // Số dư ví ảo mặc định khi khởi tạo: 0 VNĐ (Admin nạp tiền thủ công)
  static const double initialBalance = 0.0;

  // Ngưỡng cháy túi: dưới 50.000 VNĐ
  static const double brokeThreshold = 50000.0;
}
