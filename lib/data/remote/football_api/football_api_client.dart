import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../domain/models/match_model.dart';
import '../../../domain/models/league_model.dart';
import '../../../domain/enums/match_status.dart';

// Client giao tiếp với Football Data API để lấy thông tin trận đấu
class FootballApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.footballBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Lấy danh sách trận đấu mới nhất từ API bằng cách gộp nhiều nguồn (trận hôm nay, sắp tới, và kết quả gần đây)
  Future<List<MatchModel>> fetchMatches() async {
    final apiKey = ApiConstants.footballApiKey;
    if (apiKey.isEmpty) {
      throw Exception('Football API Key trống. Vui lòng cấu hình trong tệp .env');
    }

    final headers = {'Authorization': 'Bearer $apiKey'};
    final endpoints = [
      '/fixtures/live',
      '/fixtures/upcoming',
      '/fixtures/results'
    ];

    try {
      // Gọi cả 3 endpoint song song để tối ưu tốc độ, bắt lỗi riêng từng endpoint để không bị sập toàn bộ
      final responses = await Future.wait(
        endpoints.map((path) => _dio
            .get(path, options: Options(headers: headers))
            .catchError((error) {
              // Bỏ qua lỗi của endpoint riêng lẻ, trả về data rỗng để tiếp tục xử lý các endpoint khác
              return Response(
                requestOptions: RequestOptions(path: path),
                data: {
                  'success': true,
                  'data': {'matches': []}
                },
              );
            }))
      );

      final List<MatchModel> allMatches = [];
      final Set<String> uniqueIds = {};

      for (var response in responses) {
        final matchesJson = response.data['data']?['matches'] as List<dynamic>? ?? [];
        for (var json in matchesJson) {
          final id = json['match_id']?.toString() ?? '';
          if (id.isEmpty) continue;
          
          // Tránh trùng lặp trận đấu giữa các API
          if (uniqueIds.contains(id)) continue;
          uniqueIds.add(id);

          final homeTeam = json['home_team']?['team_name'] as String? ?? '';
          final awayTeam = json['away_team']?['team_name'] as String? ?? '';
          
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

          allMatches.add(
            MatchModel(
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
            ),
          );
        }
      }
      return allMatches;
    } catch (e) {
      throw Exception('Lỗi khi gọi Football API: $e');
    }
  }

  // Lấy danh sách các giải đấu từ API
  Future<List<LeagueModel>> fetchLeagues() async {
    final apiKey = ApiConstants.footballApiKey;
    if (apiKey.isEmpty) throw Exception('Football API Key trống.');
    try {
      final response = await _dio.get(
        '/leagues',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );
      final data = response.data;
      List<dynamic> raw = [];
      if (data is Map) {
        raw = data['data'] as List<dynamic>? ??
            data['leagues'] as List<dynamic>? ??
            data['results'] as List<dynamic>? ??
            [];
      } else if (data is List) {
        raw = data;
      }
      return raw
          .map((e) => LeagueModel.fromJson(e as Map<String, dynamic>))
          .where((l) => l.id.isNotEmpty && l.name.isNotEmpty)
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi lấy danh sách giải đấu: $e');
    }
  }

  // ── Helper: parse danh sách raw JSON thành MatchModel ──
  List<MatchModel> _parseMatches(List<dynamic> raw, String leagueName) {
    final List<MatchModel> matches = [];
    for (var json in raw) {
      try {
        final id = json['match_id']?.toString() ?? json['id']?.toString() ?? '';
        if (id.isEmpty) continue;
        final dateUnix = json['date_unix'] as int?;
        final utcDate = dateUnix != null
            ? DateTime.fromMillisecondsSinceEpoch(dateUnix * 1000, isUtc: true)
            : DateTime.now();
        final statusString = json['status'] as String? ?? '';
        final status = switch (statusString) {
          'complete' => MatchStatus.finished,
          'in_progress' => MatchStatus.inPlay,
          _ => MatchStatus.scheduled, // 'incomplete', 'postponed', etc.
        };
        final lName = json['league']?['competition_name'] as String? ??
            json['league']?['name'] as String? ??
            json['competition']?['name'] as String? ??
            leagueName;
        matches.add(MatchModel(
          id: id,
          homeTeam: json['home_team']?['team_name'] as String? ?? '',
          awayTeam: json['away_team']?['team_name'] as String? ?? '',
          utcDate: utcDate,
          status: status,
          scoreHome: json['score']?['home'] as int? ?? 0,
          scoreAway: json['score']?['away'] as int? ?? 0,
          oddsOver: (json['odds']?['away_win'] as num?)?.toDouble() ?? 1.85,
          oddsUnder: (json['odds']?['home_win'] as num?)?.toDouble() ?? 1.95,
          oddsDraw: (json['odds']?['draw'] as num?)?.toDouble() ?? 3.2,
          overUnderLine: 2.5,
          isSimulated: false,
          leagueName: lName,
          homeTeamLogo: json['home_team']?['team_logo'] as String? ?? '',
          awayTeamLogo: json['away_team']?['team_logo'] as String? ?? '',
        ));
      } catch (_) {
        continue;
      }
    }
    return matches;
  }

  // ── Lấy season_id phù hợp nhất của một giải ──
  // Ưu tiên: season đang diễn ra hoặc gần nhất, có trận đấu thực tế
  Future<int?> _fetchLatestSeasonId(String leagueId, String apiKey) async {
    try {
      final res = await _dio.get(
        '/leagues/$leagueId/seasons',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );
      final seasons =
          res.data?['data']?['seasons'] as List<dynamic>? ?? [];
      if (seasons.isEmpty) return null;

      final now = DateTime.now();

      // Chuyển về list có đủ thông tin
      final parsed = <Map<String, dynamic>>[];
      for (var s in seasons) {
        final matchCount = (s['summary']?['match_count'] as num?)?.toInt() ?? 0;
        final firstDateStr = s['summary']?['first_match_date'] as String?;
        final lastDateStr = s['summary']?['last_match_date'] as String?;
        final id = (s['season_id'] as num?)?.toInt();
        if (id == null || matchCount == 0) continue; // bỏ season rỗng

        DateTime? firstDate;
        DateTime? lastDate;
        try {
          if (firstDateStr != null) firstDate = DateTime.parse(firstDateStr);
          if (lastDateStr != null) lastDate = DateTime.parse(lastDateStr);
        } catch (_) {}

        parsed.add({
          'id': id,
          'matchCount': matchCount,
          'firstDate': firstDate,
          'lastDate': lastDate,
          'raw_year': (s['year'] as num?)?.toInt() ?? 0,
        });
      }

      if (parsed.isEmpty) return null;

      // Ưu tiên 1: season đang diễn ra (firstDate <= now <= lastDate)
      final ongoing = parsed.where((s) {
        final fd = s['firstDate'] as DateTime?;
        final ld = s['lastDate'] as DateTime?;
        return fd != null && ld != null && fd.isBefore(now) && ld.isAfter(now);
      }).toList();

      if (ongoing.isNotEmpty) {
        // Trong các season đang chạy, lấy cái có lastDate xa nhất (mới nhất)
        ongoing.sort((a, b) {
          final la = a['lastDate'] as DateTime;
          final lb = b['lastDate'] as DateTime;
          return lb.compareTo(la);
        });
        return ongoing.first['id'] as int;
      }

      // Ưu tiên 2: season sắp tới gần nhất (firstDate > now, có trận)
      final upcoming = parsed.where((s) {
        final fd = s['firstDate'] as DateTime?;
        return fd != null && fd.isAfter(now);
      }).toList();

      if (upcoming.isNotEmpty) {
        upcoming.sort((a, b) {
          final fa = a['firstDate'] as DateTime;
          final fb = b['firstDate'] as DateTime;
          return fa.compareTo(fb); // gần nhất trước
        });
        return upcoming.first['id'] as int;
      }

      // Fallback: season kết thúc gần đây nhất (lastDate lớn nhất)
      parsed.sort((a, b) {
        final la = a['lastDate'] as DateTime? ?? DateTime(2000);
        final lb = b['lastDate'] as DateTime? ?? DateTime(2000);
        return lb.compareTo(la);
      });
      return parsed.first['id'] as int;
    } catch (_) {
      return null;
    }
  }

  // ── Lấy trận đấu theo season_id ──
  Future<List<MatchModel>> _fetchSeasonMatches(
      int seasonId, String leagueName, String apiKey) async {
    final res = await _dio.get(
      '/seasons/$seasonId/matches',
      options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
    );
    final data = res.data;
    List<dynamic> raw = [];
    if (data is Map) {
      raw = data['data']?['matches'] as List<dynamic>? ??
          data['matches'] as List<dynamic>? ??
          data['data'] as List<dynamic>? ??
          [];
    } else if (data is List) {
      raw = data;
    }
    return _parseMatches(raw, leagueName);
  }

  // ── Public: Lấy trận mới nhất của một giải (tự động dùng season hiện tại) ──
  Future<List<MatchModel>> fetchLeagueMatches(
    String leagueId, {
    String leagueName = '',
  }) async {
    final apiKey = ApiConstants.footballApiKey;
    if (apiKey.isEmpty) throw Exception('Football API Key trống.');
    try {
      // Bước 1: Lấy season mới nhất
      final seasonId = await _fetchLatestSeasonId(leagueId, apiKey);

      if (seasonId != null) {
        // Bước 2: Lấy trận theo season → data 2026 mới nhất
        try {
          return await _fetchSeasonMatches(seasonId, leagueName, apiKey);
        } catch (_) {
          // fallback về endpoint gốc nếu season fails
        }
      }

      // Fallback: dùng /leagues/{id}/matches
      final response = await _dio.get(
        '/leagues/$leagueId/matches',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );
      final data = response.data;
      List<dynamic> raw = [];
      if (data is Map) {
        raw = data['data']?['matches'] as List<dynamic>? ??
            data['matches'] as List<dynamic>? ??
            data['data'] as List<dynamic>? ??
            [];
      } else if (data is List) {
        raw = data;
      }
      return _parseMatches(raw, leagueName);
    } catch (e) {
      throw Exception('Lỗi khi lấy trận đấu giải $leagueId: $e');
    }
  }
}

