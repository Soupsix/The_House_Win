import 'dart:async';
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
  StreamSubscription<List<MatchModel>>? _matchesSubscription;

  MatchNotifier(
    this._apiClient,
    this._firestoreService,
    this._dbHelper,
  ) : super(const MatchState()) {
    // Bắt đầu lắng nghe Firestore realtime ngay khi khởi tạo
    _startWatchingMatches();
  }

  @override
  void dispose() {
    _matchesSubscription?.cancel();
    super.dispose();
  }

  // Lắng nghe realtime stream từ Firestore
  void _startWatchingMatches() {
    _matchesSubscription?.cancel();
    _matchesSubscription = _firestoreService.streamMatches().listen(
      (firestoreMatches) async {
        // Lấy thêm các trận từ SQLite cache (các trận đấu từ API đã lưu)
        List<MatchModel> cachedMatches = [];
        try {
          final db = await _dbHelper.database;
          final List<Map<String, dynamic>> maps = await db.query('match_cache');
          cachedMatches = maps.map((map) => MatchModel.fromSQLite(map)).toList();
        } catch (_) {}

        // Gộp hai nguồn, ưu tiên firestoreMatches (simulated)
        final allMatchIds = <String>{};
        final allMatches = <MatchModel>[];

        for (var m in firestoreMatches) {
          allMatchIds.add(m.id);
          allMatches.add(m);
        }

        for (var m in cachedMatches) {
          if (!allMatchIds.contains(m.id)) {
            allMatches.add(m);
          }
        }

        final scheduled =
            allMatches.where((m) => m.status == MatchStatus.scheduled).toList();
        final live =
            allMatches.where((m) => m.status == MatchStatus.inPlay).toList();
        final finished =
            allMatches.where((m) => m.status == MatchStatus.finished).toList();

        state = state.copyWith(
          scheduledMatches: scheduled,
          liveMatches: live,
          finishedMatches: finished,
          isRefreshing: false,
        );
      },
      onError: (_) {
        // Nếu không có quyền (guest), bỏ qua — loadFromCache sẽ xử lý
      },
    );
  }

  // Gán BetsNotifier để trigger giải quyết cược khi trận đấu kết thúc
  void setBetsSettler(IBetsSettler settler) {
    _betsSettler = settler;
  }


  // Đồng bộ danh sách trận đấu mới nhất từ Football API về SQLite và cập nhật State
  Future<void> syncFromApi() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final apiMatches = await _apiClient.fetchMatches();

      // Lưu API matches vào SQLite local (không cần Firestore permission)
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (var match in apiMatches) {
        batch.insert(
          'match_cache',
          match.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      // Lấy thêm các trận giả lập từ Firestore (nếu có quyền)
      List<MatchModel> firestoreMatches = [];
      try {
        firestoreMatches = await _firestoreService.getAllMatches();
      } catch (_) {
        // Không có quyền đọc Firestore (guest), bỏ qua
      }

      // Gộp: ưu tiên Firestore (có kèo tỷ lệ chính xác) + API (có tỪ mới)
      final allMatchIds = <String>{};
      final allMatches = <MatchModel>[];

      // Thêm Firestore trước
      for (var m in firestoreMatches) {
        allMatchIds.add(m.id);
        allMatches.add(m);
      }
      // Thêm API matches không bị trùng
      for (var m in apiMatches) {
        if (!allMatchIds.contains(m.id)) {
          allMatches.add(m);
        }
      }

      // Phân loại trận đấu theo trạng thái
      final scheduled = allMatches
          .where((m) => m.status == MatchStatus.scheduled)
          .toList();
      final live =
          allMatches.where((m) => m.status == MatchStatus.inPlay).toList();
      final finished = allMatches
          .where((m) => m.status == MatchStatus.finished)
          .toList();

      state = state.copyWith(
        scheduledMatches: scheduled,
        liveMatches: live,
        finishedMatches: finished,
        isRefreshing: false,
        lastSyncAt: DateTime.now(),
      );
    } catch (e) {
      // Nếu API lỗi, tải lại dữ liệu từ Firestore/SQLite cache
      await loadFromCache();
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi đồng bộ API: $e',
      );
    }
  }

  // Admin đồng bộ lịch thi đấu từ API lên Firestore (để tất cả user thấy)
  Future<int> adminSyncApiToFirestore() async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      final apiMatches = await _apiClient.fetchMatches();
      int savedCount = 0;

      for (final match in apiMatches) {
        // Chỉ lưu nếu chưa có trong Firestore (không ghi đè trận giả lập)
        try {
          await _firestoreService.saveMatchInFirestore(
            match.id,
            match.toFirestore(),
          );
          savedCount++;
        } catch (_) {
          // Bỏ qua nếu document đã tồn tại hoặc lỗi permission
        }
      }

      // Cũng lưu vào SQLite local
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (var match in apiMatches) {
        batch.insert(
          'match_cache',
          match.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);

      state = state.copyWith(isRefreshing: false);
      return savedCount;
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi đồng bộ lịch lên Firestore: $e',
      );
      return 0;
    }
  }

  // Tải danh sách trận đấu từ Firestore (và SQLite) lên State khi khởi chạy
  Future<void> loadFromCache() async {
    try {
      List<MatchModel> firestoreMatches = [];
      try {
        firestoreMatches = await _firestoreService.getAllMatches();
      } catch (_) {}

      List<MatchModel> cachedMatches = [];
      try {
        final db = await _dbHelper.database;
        final List<Map<String, dynamic>> maps = await db.query('match_cache');
        cachedMatches = maps.map((map) => MatchModel.fromSQLite(map)).toList();
      } catch (_) {}

      // Gộp: ưu tiên Firestore
      final allMatchIds = <String>{};
      final allMatches = <MatchModel>[];

      for (var m in firestoreMatches) {
        allMatchIds.add(m.id);
        allMatches.add(m);
      }

      for (var m in cachedMatches) {
        if (!allMatchIds.contains(m.id)) {
          allMatches.add(m);
        }
      }

      final scheduled = allMatches.where((m) => m.status == MatchStatus.scheduled).toList();
      final live = allMatches.where((m) => m.status == MatchStatus.inPlay).toList();
      final finished = allMatches.where((m) => m.status == MatchStatus.finished).toList();

      state = state.copyWith(
        scheduledMatches: scheduled,
        liveMatches: live,
        finishedMatches: finished,
        isRefreshing: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
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

      // Cập nhật state NGAY LẬP TỨC — không đợi reload
      final updatedScheduled = [...state.scheduledMatches, simulated];
      state = state.copyWith(
        scheduledMatches: updatedScheduled,
        isRefreshing: false,
      );

      // Sau đó reload đầy đủ từ Firestore để đảm bảo đồng bộ
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

  // Admin cập nhật tỷ lệ cược của trận đấu
  Future<void> adminUpdateOdds({
    required String matchId,
    required double oddsOver,
    required double oddsUnder,
    required double overUnderLine,
  }) async {
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      // 1. Đọc trận đấu hiện tại từ local state
      final allMatches = [
        ...state.scheduledMatches,
        ...state.liveMatches,
        ...state.finishedMatches
      ];
      final match = allMatches.firstWhere((m) => m.id == matchId);
      final updatedMatch = match.copyWith(
        oddsOver: oddsOver,
        oddsUnder: oddsUnder,
        overUnderLine: overUnderLine,
      );

      // 2. Lưu vào Firestore
      await _firestoreService.saveMatchInFirestore(matchId, updatedMatch.toFirestore());

      // 3. Lưu vào SQLite
      final db = await _dbHelper.database;
      await db.update(
        'match_cache',
        updatedMatch.toSQLite(),
        where: 'id = ?',
        whereArgs: [matchId],
      );

      // 4. Ghi log hành động admin
      await _firestoreService.writeAdminLog('UPDATE_MATCH_ODDS', {
        'matchId': matchId,
        'oddsOver': oddsOver,
        'oddsUnder': oddsUnder,
        'overUnderLine': overUnderLine,
      });

      await loadFromCache();
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi khi cập nhật tỷ lệ cược: $e',
      );
    }
  }
}

