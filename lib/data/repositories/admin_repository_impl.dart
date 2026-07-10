import '../../domain/models/user_model.dart';
import '../../domain/repositories/i_admin_repository.dart';
import '../firebase/firestore_service.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final FirestoreService _firestoreService;

  AdminRepositoryImpl(this._firestoreService);

  // ================= USERS =================

  @override
  Stream<List<UserModel>> watchAllUsers() {
    return _firestoreService.watchAllUsers();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAllWallets() {
    return _firestoreService.watchAllWallets();
  }

  @override
  Future<void> resetUserWallet(String uid) async {
    await _firestoreService.runResetWalletTransaction(uid);
  }

  @override
  Future<void> adminEditBalance({
    required String uid,
    required double newBalance,
  }) async {
    await _firestoreService.runAdminEditBalanceTransaction(
      uid: uid,
      newBalance: newBalance,
    );
  }

  @override
  Future<void> toggleUserAdminStatus(
      String uid,
      bool isAdmin,
      ) async {
    await _firestoreService.toggleUserAdminStatus(
      uid,
      isAdmin,
    );
  }

  // ================= WITHDRAWALS =================

  @override
  Stream<List<Map<String, dynamic>>> watchWithdrawalRequests() {
    return _firestoreService.watchWithdrawalRequests();
  }

  @override
  Future<void> approveWithdrawal({
    required String requestId,
    required String uid,
    required double amount,
  }) async {
    await _firestoreService.runApproveWithdrawTransaction(
      requestId: requestId,
      uid: uid,
      amount: amount,
    );
  }

  @override
  Future<void> rejectWithdrawal({
    required String requestId,
  }) async {
    await _firestoreService.rejectWithdrawRequest(
      requestId: requestId,
    );
  }

  @override
  Future<void> seedMockRequests(
      String uid,
      String displayName,
      ) async {
    await _firestoreService.seedMockWithdrawalRequests(
      uid,
      displayName,
    );
  }

  // ================= MATCHES =================

  @override
  Stream<List<Map<String, dynamic>>> watchAllMatches() {
    return _firestoreService.watchAdminMatches();
  }

  @override
  Future<void> updateMatchOdds({
    required String matchId,
    required double overOdds,
    required double underOdds,
    required double line,
  }) async {
    await _firestoreService.updateAdminMatchOdds(
      matchId: matchId,
      overOdds: overOdds,
      underOdds: underOdds,
      line: line,
    );
  }

  @override
  Future<void> forceMatchResult({
    required String matchId,
    required String result,
  }) async {
    await _firestoreService.forceAdminMatchResult(
      matchId: matchId,
      result: result,
    );
  }

  @override
  Future<void> updateMatchBettingLock({
    required String matchId,
    required bool isLocked,
  }) async {
    await _firestoreService.updateAdminMatchBettingLock(
      matchId: matchId,
      isLocked: isLocked,
    );
  }

  // ================= LOGS =================

  @override
  Stream<List<Map<String, dynamic>>> watchAdminLogs() {
    return _firestoreService.watchAdminLogs();
  }

  // ================= SETTINGS =================

  @override
  Stream<Map<String, dynamic>> watchAdminSettings(
      String adminId,
      ) {
    return _firestoreService.watchAdminSettingsData(adminId);
  }

  @override
  Future<void> updateAntiGamblingSettings({
    required String adminId,
    required Map<String, dynamic> settings,
  }) async {
    await _firestoreService.updateAdminSettingsData(
      adminId: adminId,
      data: {
        'antiGambling': settings,
      },
    );
  }

  @override
  Future<void> updateEducationContent({
    required String adminId,
    required Map<String, dynamic> content,
  }) async {
    await _firestoreService.updateAdminSettingsData(
      adminId: adminId,
      data: {
        'educationContent': content,
      },
    );
  }
}