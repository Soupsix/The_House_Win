import '../models/match_model.dart';
import '../enums/match_status.dart';

abstract class IMatchRepository {
  /// Đồng bộ tất cả trận đấu hôm nay từ API
  Future<List<MatchModel>> syncTodayMatches();

  /// Lấy danh sách trận đấu từ SQLite
  Future<List<MatchModel>> getCachedMatches();

  /// Lưu một trận đấu
  Future<void> saveMatch(MatchModel match);

  /// Cập nhật trận đấu
  Future<void> updateMatch(MatchModel match);

  /// Lấy chi tiết trận đấu
  Future<MatchModel?> getMatchById(String id);

  /// Tạo trận đấu giả lập
  Future<void> createSimulatedMatch(MatchModel match);

  /// Override kết quả
  Future<void> overrideResult(
      String matchId,
      MatchResult result,
      );
}