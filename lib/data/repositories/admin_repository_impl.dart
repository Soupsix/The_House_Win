import '../../domain/repositories/i_admin_repository.dart';
import '../../domain/models/user_model.dart';
import '../firebase/firestore_service.dart';

class AdminRepositoryImpl implements IAdminRepository {
  final FirestoreService _firestoreService;

  AdminRepositoryImpl(this._firestoreService);

  @override
  Stream<List<UserModel>> watchAllUsers() {
    return _firestoreService.watchAllUsers();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAllWallets() {
    return _firestoreService.watchAllWallets();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchWithdrawalRequests() {
    return _firestoreService.watchWithdrawalRequests();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchAdminLogs() {
    return _firestoreService.watchAdminLogs();
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
  Future<void> rejectWithdrawal({required String requestId}) async {
    await _firestoreService.rejectWithdrawRequest(requestId: requestId);
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
  Future<void> toggleUserAdminStatus(String uid, bool isAdmin) async {
    await _firestoreService.toggleUserAdminStatus(uid, isAdmin);
  }

  @override
  Future<void> seedMockRequests(String uid, String displayName) async {
    await _firestoreService.seedMockWithdrawalRequests(uid, displayName);
  }
}
