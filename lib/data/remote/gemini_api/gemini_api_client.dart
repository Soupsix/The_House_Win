import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import 'package:flutter/foundation.dart';

class GeminiApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.geminiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<String> generateContent(String prompt) async {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Gemini API Key trống. Vui lòng cấu hình trong tệp .env');
    }

    try {
      final response = await _dio.post(
        '${ApiConstants.geminiBaseUrl}/models/gemini-3.5-flash:generateContent',
        queryParameters: {'key': apiKey},
        data: {
          "contents": [
            {
              "parts": [
                {"text": prompt}
              ]
            }
          ]
        },
      );

      final candidates = response.data['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final content = candidates[0]['content'];
        final parts = content['parts'] as List<dynamic>?;
        if (parts != null && parts.isNotEmpty) {
          return parts[0]['text'] as String;
        }
      }
      return 'Không có kết quả trả về từ AI.';
    } on DioException catch (e) {
      if (kDebugMode) {
        print('Gemini API Error: ${e.response?.data ?? e.message}');
      }
      throw Exception('Lỗi kết nối AI: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi xử lý phản hồi từ AI: $e');
    }
  }
}
