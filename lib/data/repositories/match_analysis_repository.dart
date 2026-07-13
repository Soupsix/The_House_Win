import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/match_model.dart';
import '../remote/gemini_api/gemini_api_client.dart';

final matchAnalysisRepositoryProvider = Provider<MatchAnalysisRepository>((ref) {
  return MatchAnalysisRepositoryImpl(GeminiApiClient());
});

abstract class MatchAnalysisRepository {
  Future<String> analyzeMatch(MatchModel match);
}

class MatchAnalysisRepositoryImpl implements MatchAnalysisRepository {
  final GeminiApiClient _geminiApiClient;
  // In-memory cache to avoid repeated expensive API calls
  final Map<String, String> _cache = {};

  MatchAnalysisRepositoryImpl(this._geminiApiClient);

  @override
  Future<String> analyzeMatch(MatchModel match) async {
    if (_cache.containsKey(match.id)) {
      return _cache[match.id]!;
    }

    final prompt = '''
Bạn là một chuyên gia phân tích dữ liệu và thống kê bóng đá. 
Hãy phân tích trận đấu dưới đây DỰA TRÊN SỐ LIỆU ĐƯỢC CUNG CẤP. 
TUYỆT ĐỐI KHÔNG BỊA RA các số liệu không có thực (như kết quả cụ thể của 5 trận gần nhất, tỷ lệ giữ sạch lưới, v.v.).
Nếu thiếu dữ liệu, hãy phân tích dựa trên Tỷ lệ cược (Odds) vì Odds phản ánh xác suất thực tế từ nhà cái. Hãy ghi rõ việc thiếu dữ liệu làm giảm độ tin cậy.

Thông tin trận đấu:
- Giải đấu: ${match.leagueName.isNotEmpty ? match.leagueName : 'Không rõ'}
- Đội nhà: ${match.homeTeam}
- Đội khách: ${match.awayTeam}
- Tỷ lệ cược (Châu Âu 1X2):
  + Đội nhà thắng: x${match.oddsOver}
  + Hai đội hòa: x${match.oddsDraw}
  + Đội khách thắng: x${match.oddsUnder}
- Mốc Tài Xỉu (Over/Under): ${match.overUnderLine} trái

Yêu cầu trả lời bằng Markdown, rõ ràng, súc tích (dưới 300 từ) và BẮT BUỘC CÓ ĐỦ 9 MỤC SAU:
### 1. Match Overview
### 2. Home Team Analysis
### 3. Away Team Analysis
### 4. Head-to-head Trends
### 5. Goal Scoring Trends
### 6. Over/Under (O/U) Analysis
### 7. Key Risk Factors
### 8. Confidence Level (Low / Medium / High)
### 9. Educational Reminder
(Phải nhấn mạnh bóng đá là không thể đoán trước, thống kê quá khứ không đảm bảo tương lai, và phân tích này CHỈ DÀNH CHO MỤC ĐÍCH GIÁO DỤC, không dùng để cá cược).
''';

    final result = await _geminiApiClient.generateContent(prompt);
    _cache[match.id] = result;
    return result;
  }
}
