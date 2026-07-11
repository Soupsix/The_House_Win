import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../domain/enums/match_status.dart';
import '../../../domain/models/match_model.dart';

class FootballApiClient {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.footballBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<List<MatchModel>> fetchMatches() async {
    final apiKey = ApiConstants.footballApiKey;

    if (apiKey.isEmpty) {
      throw Exception("Football API Key không tồn tại");
    }

    try {
      final response = await _dio.get(
        "/fixtures/today",
        options: Options(
          headers: {
            "Authorization": "Bearer $apiKey",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception("Không thể lấy dữ liệu trận đấu");
      }

      final body = response.data;

      if (body["success"] != true) {
        throw Exception("API trả về thất bại");
      }

      final List matches =
          body["data"]["matches"] as List<dynamic>? ?? [];

      return matches.map((json) {
        final status =
        (json["status"] ?? "").toString().toLowerCase();

        MatchStatus matchStatus;

        switch (status) {
          case "finished":
            matchStatus = MatchStatus.finished;
            break;

          case "live":
          case "inplay":
          case "in_play":
            matchStatus = MatchStatus.inPlay;
            break;

          default:
            matchStatus = MatchStatus.scheduled;
        }

        return MatchModel(
          id: json["match_id"].toString(),

          homeTeam:
          json["home_team"]["team_name"] ?? "Unknown",

          awayTeam:
          json["away_team"]["team_name"] ?? "Unknown",

          utcDate: DateTime.parse(
            json["match_date"],
          ),

          status: matchStatus,

          scoreHome:
          (json["score"]["home"] ?? 0) as int,

          scoreAway:
          (json["score"]["away"] ?? 0) as int,

          // App của mình dùng Over/Under
          oddsOver: 1.85,

          oddsUnder: 1.95,

          overUnderLine: 2.5,

          isSimulated: false,
        );
      }).toList();
    } on DioException catch (e) {
      throw Exception(
        "Lỗi kết nối API: ${e.message}",
      );
    } catch (e) {
      throw Exception(
        "Lỗi parse dữ liệu trận đấu: $e",
      );
    }
  }
}