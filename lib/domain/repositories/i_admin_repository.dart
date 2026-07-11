import '../models/user_model.dart';

abstract class IAdminRepository {
  // 11.2 - Danh sách người chơi
  Stream<List<UserModel>> watchAllUsers();
  Stream<List<Map<String, dynamic>>> watchAdminMatches();

  Stream<List<Map<String, dynamic>>> watchAllWallets();

  // 11.5 - Yêu cầu rút tiền ảo
  Stream<List<Map<String, dynamic>>> watchWithdrawalRequests();

  Future<void> approveWithdrawal({
    required String requestId,
    required String uid,
    required double amount,
  });

  Future<void> rejectWithdrawal({
    required String requestId,
  });

  Future<void> resetUserWallet(String uid);

  Future<void> adminEditBalance({
    required String uid,
    required double newBalance,
  });

  Future<void> toggleUserAdminStatus(
    String uid,
    bool isAdmin,
  );

  Future<void> seedMockRequests(
    String uid,
    String displayName,
  );

  // 11.3, 11.4, 11.6 - Quản lý trận và cược
  Stream<List<Map<String, dynamic>>> watchAllMatches();

  Future<void> updateMatchOdds({
    required String matchId,
    required double overOdds,
    required double underOdds,
    required double line,
  });

  Future<void> forceMatchResult({
    required String matchId,
    required String result,
  });

  Future<void> updateMatchBettingLock({
    required String matchId,
    required bool isLocked,
  });

  // 11.7 - Log hành động Admin
  Stream<List<Map<String, dynamic>>> watchAdminLogs();

  // 11.8, 11.9 - Cấu hình Admin
  Stream<Map<String, dynamic>> watchAdminSettings(
    String adminId,
  );

  Future<void> updateAntiGamblingSettings({
    required String adminId,
    required Map<String, dynamic> settings,
  });

  Future<void> updateEducationContent({
    required String adminId,
    required Map<String, dynamic> content,
  });
}
