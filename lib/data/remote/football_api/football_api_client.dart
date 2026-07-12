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
        '/fixtures/today',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      final matchesJson = response.data['data']['matches'] as List<dynamic>? ?? [];
      return matchesJson.map((json) {
        final id = json['match_id'].toString();
        final homeTeam = json['home_team']['team_name'] as String? ?? '';
        final awayTeam = json['away_team']['team_name'] as String? ?? '';
        
        final dateUnix = json['date_unix'] as int?;
        final utcDate = dateUnix != null 
            ? DateTime.fromMillisecondsSinceEpoch(dateUnix * 1000, isUtc: true)
            : DateTime.now();
            
        final statusString = json['status'] as String? ?? '';

        final status = switch (statusString) {
          'complete' => MatchStatus.finished,
          'in_progress' => MatchStatus.inPlay,
          _ => MatchStatus.scheduled,
        };

        final scoreHome = json['score']?['home'] as int? ?? 0;
        final scoreAway = json['score']?['away'] as int? ?? 0;

        return MatchModel(
          id: id,
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          utcDate: utcDate,
          status: status,
          scoreHome: scoreHome,
          scoreAway: scoreAway,
          oddsOver: (json['odds']?['away_win'] as num?)?.toDouble() ?? 1.85,
          oddsUnder: (json['odds']?['home_win'] as num?)?.toDouble() ?? 1.95,
          oddsDraw: (json['odds']?['draw'] as num?)?.toDouble() ?? 3.2,
          overUnderLine: 2.5,
          isSimulated: false,
          leagueName: json['league']?['competition_name'] as String? ?? '',
          homeTeamLogo: json['home_team']?['team_logo'] as String? ?? '',
          awayTeamLogo: json['away_team']?['team_logo'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi gọi Football API: $e');
    }
  }
}
