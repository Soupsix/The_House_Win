import '../../domain/models/user_model.dart';

abstract class IAdminRepository {
  Stream<List<UserModel>> watchAllUsers();
  Stream<List<Map<String, dynamic>>> watchAllWallets();
  Stream<List<Map<String, dynamic>>> watchWithdrawalRequests();
  Stream<List<Map<String, dynamic>>> watchAdminLogs();
  
  Future<void> approveWithdrawal({
    required String requestId,
    required String uid,
    required double amount,
  });

  Future<void> rejectWithdrawal({required String requestId});
  
  Future<void> resetUserWallet(String uid);
  
  Future<void> adminEditBalance({
    required String uid,
    required double newBalance,
  });
  
  Future<void> toggleUserAdminStatus(String uid, bool isAdmin);
  
  Future<void> seedMockRequests(String uid, String displayName);
}
