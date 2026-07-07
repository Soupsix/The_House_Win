import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../domain/models/match_model.dart';
import '../../../domain/enums/match_status.dart';

// Client giao tiếp với Football Data API để lấy thông tin trận đấu
class FootballApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.footballBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Lấy danh sách trận đấu mới nhất từ API
  Future<List<MatchModel>> fetchMatches() async {
    final apiKey = ApiConstants.footballApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Football API Key trống. Vui lòng cấu hình trong tệp .env');
    }

    try {
      final response = await _dio.get(
        '/matches',
        options: Options(headers: {'X-Auth-Token': apiKey}),
      );

      final matchesJson = response.data['matches'] as List<dynamic>? ?? [];
      return matchesJson.map((json) {
        final id = json['id'].toString();
        final homeTeam = json['homeTeam']['name'] as String? ?? '';
        final awayTeam = json['awayTeam']['name'] as String? ?? '';
        final utcDate = DateTime.parse(json['utcDate'] as String);
        final statusString = json['status'] as String? ?? '';

        final status = switch (statusString) {
          'FINISHED' => MatchStatus.finished,
          'IN_PLAY' || 'PAUSED' => MatchStatus.inPlay,
          _ => MatchStatus.scheduled,
        };

        final scoreHome = json['score']?['fullTime']?['home'] as int? ?? 0;
        final scoreAway = json['score']?['fullTime']?['away'] as int? ?? 0;

        return MatchModel(
          id: id,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          utcDate: utcDate,
          status: status,
          scoreHome: scoreHome,
          scoreAway: scoreAway,
          oddsOver: 1.85,
          oddsUnder: 1.95,
          overUnderLine: 2.5,
          isSimulated: false,
        );
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi gọi Football API: $e');
    }
  }
}
