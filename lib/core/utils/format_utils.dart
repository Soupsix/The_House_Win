import 'package:intl/intl.dart';

class FormatUtils {
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('HH:mm dd/MM').format(date);
  }
}
