import 'package:flutter_dotenv/flutter_dotenv.dart';

// Các hằng số liên quan đến API và Endpoint
class ApiConstants {
  ApiConstants._();

  // Lấy API key cho Football Data từ biến môi trường
  static String get footballApiKey =>
      dotenv.env['FOOTBALL_DATA_API_KEY'] ?? '';

  // Lấy API key cho Gemini từ biến môi trường
  static String get geminiApiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? '';

  // URL gốc của Football Data API (footballdata.io)
  static const String footballBaseUrl = 'https://footballdata.io/api/v1';

  // URL gốc của Gemini API v1beta
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
}
