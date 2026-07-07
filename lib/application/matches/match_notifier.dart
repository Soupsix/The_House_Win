import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'match_state.dart';
import '../../data/remote/football_api/football_api_client.dart';
import '../../data/firebase/firestore_service.dart';
import '../../data/local/database_helper.dart';
import '../../domain/models/match_model.dart';
import '../../domain/enums/match_status.dart';

// Notifier khác có thể được gán động để tránh vòng lặp phụ thuộc cyclic
abstract class IBetsSettler {
  Future<void> onMatchSettled(String matchId, MatchResult result);
}

// Notifier quản lý danh sách trận đấu bóng đá
class MatchNotifier extends StateNotifier<MatchState> {
  final FootballApiClient _apiClient;
  final FirestoreService _firestoreService;
  final DatabaseHelper _dbHelper;
  IBetsSettler? _betsSettler;

  MatchNotifier(
    this._apiClient,
    this._firestoreService,
    this._dbHelper,
  ) : super(const MatchState());

  // Gán BetsNotifier để trigger giải quyết cược khi trận đấu kết thúc
  void setBetsSettler(IBetsSettler settler) {
    _betsSettler = settler;
  }

  // Đồng bộ danh sách trận đấu mới nhất từ Football API về SQLite và cập nhật State
  Future<void> syncFromApi() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final matches = await _apiClient.fetchMatches();
      
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (var match in matches) {
        batch.insert(
          'match_cache',
          match.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      // Phân loại trận đấu theo trạng thái
      final scheduled = matches.where((m) => m.status == MatchStatus.scheduled).toList();
      final live = matches.where((m) => m.status == MatchStatus.inPlay).toList();
      final finished = matches.where((m) => m.status == MatchStatus.finished).toList();

      state = state.copyWith(
        scheduledMatches: scheduled,
        liveMatches: live,
        finishedMatches: finished,
        isRefreshing: false,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      // Nếu API lỗi, tải lại dữ liệu từ SQLite cache để hiển thị
      await loadFromCache();
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi đồng bộ API bóng đá: $e. Đã tải dữ liệu từ bộ nhớ tạm.',
      );
    }
  }

  // Tải danh sách trận đấu từ SQLite local cache lên State khi khởi chạy ứng dụng
  Future<void> loadFromCache() async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('match_cache');
      final matches = maps.map((map) => MatchModel.fromSQLite(map)).toList();

      final scheduled = matches.where((m) => m.status == MatchStatus.scheduled).toList();
      final live = matches.where((m) => m.status == MatchStatus.inPlay).toList();
      final finished = matches.where((m) => m.status == MatchStatus.finished).toList();

      state = state.copyWith(
        scheduledMatches: scheduled,
        liveMatches: live,
        finishedMatches: finished,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi tải cache SQLite: $e',
      );
    }
  }

  // Cập nhật tỷ số trực tiếp và tự động giải quyết các trận đấu đã kết thúc
  Future<void> updateLiveScores() async {
    if (state.liveMatches.isEmpty) return;

    final oldLiveMatches = List<MatchModel>.from(state.liveMatches);
    await syncFromApi();

    // Duyệt qua các trận đấu đang phát trực tiếp trước đó
    for (var oldMatch in oldLiveMatches) {
      final allMatches = [
        ...state.scheduledMatches,
        ...state.liveMatches,
        ...state.finishedMatches
      ];
      final updatedMatch = allMatches.firstWhere(
        (m) => m.id == oldMatch.id,
        orElse: () => oldMatch,
      );

      // Nếu trận đấu đã kết thúc, tiến hành settle kết quả cược
      if (updatedMatch.status == MatchStatus.finished &&
          oldMatch.status == MatchStatus.inPlay) {
        final totalGoals = updatedMatch.scoreHome + updatedMatch.scoreAway;
        final result = (totalGoals > updatedMatch.overUnderLine)
            ? MatchResult.over
            : (totalGoals < updatedMatch.overUnderLine)
                ? MatchResult.under
                : MatchResult.push;

        await settleMatch(updatedMatch.id, result);
      }
    }
  }

  // Thực hiện giải quyết kết quả trận đấu bóng đá và cập nhật lịch sử đặt cược
  Future<void> settleMatch(String matchId, MatchResult result) async {
    try {
      // 1. Cập nhật kết quả trong Firestore
      await _firestoreService.settleMatchInFirestore(matchId, result.name);

      // 2. Cập nhật SQLite
      final db = await _dbHelper.database;
      await db.update(
        'match_cache',
        {
          'status': MatchStatus.finished.name,
          'result': result.name,
          'synced_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [matchId],
      );

      // 3. Tải lại cache lên state
      await loadFromCache();

      // 4. Trigger BetsNotifier giải quyết các cược liên quan
      if (_betsSettler != null) {
        await _betsSettler!.onMatchSettled(matchId, result);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi khi giải quyết trận đấu: $e',
      );
    }
  }

  // Chọn một trận đấu cụ thể để xem chi tiết
  void selectMatch(MatchModel match) {
    state = state.copyWith(selectedMatch: match);
  }

  // Admin tạo trận đấu giả lập mới
  Future<void> createSimulatedMatch(MatchModel match) async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final simulated = match.copyWith(isSimulated: true);
      
      // Lưu vào Firestore
      await _firestoreService.saveMatchInFirestore(
        simulated.id,
        simulated.toFirestore(),
      );

      // Lưu vào SQLite
      final db = await _dbHelper.database;
      await db.insert(
        'match_cache',
        simulated.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await loadFromCache();
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi khi tạo trận đấu giả lập: $e',
      );
    }
  }

  // Admin can thiệp cưỡng chế thay đổi kết quả một trận đấu
  Future<void> adminOverrideResult(String matchId, MatchResult result) async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      // Ghi log hành động admin vào Firestore
      await _firestoreService.writeAdminLog('OVERRIDE_MATCH_RESULT', {
        'matchId': matchId,
        'result': result.name,
      });

      // Thực hiện giải quyết trận đấu với kết quả mới
      await settleMatch(matchId, result);
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi admin can thiệp kết quả: $e',
      );
    }
  }
}
