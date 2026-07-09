import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_state.dart';
import '../../domain/repositories/i_admin_repository.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final IAdminRepository _adminRepository;

  StreamSubscription? _usersSub;
  StreamSubscription? _walletsSub;
  StreamSubscription? _requestsSub;
  StreamSubscription? _logsSub;

  AdminNotifier(this._adminRepository) : super(const AdminState());

  void initialize() {
    _usersSub?.cancel();
    _walletsSub?.cancel();
    _requestsSub?.cancel();
    _logsSub?.cancel();

    state = state.copyWith(isLoading: true);

    // Watch users
    _usersSub = _adminRepository.watchAllUsers().listen((usersList) {
      state = state.copyWith(users: usersList, isLoading: false);
    }, onError: (e) {
      state = state.copyWith(errorMessage: 'Lỗi tải danh sách người dùng: $e', isLoading: false);
    });

    // Watch wallets to map balances
    _walletsSub = _adminRepository.watchAllWallets().listen((walletsList) {
      final balances = <String, double>{};
      for (var wallet in walletsList) {
        final userId = wallet['userId'] as String;
        final balance = wallet['balance'] as double;
        balances[userId] = balance;
      }
      state = state.copyWith(userBalances: balances);
    });

    // Watch withdrawal requests
    _requestsSub = _adminRepository.watchWithdrawalRequests().listen((requests) {
      state = state.copyWith(withdrawalRequests: requests);
    });

    // Watch admin logs
    _logsSub = _adminRepository.watchAdminLogs().listen((logs) {
      state = state.copyWith(adminLogs: logs);
    });
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> approveWithdrawal(String requestId, String userId, double amount) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _adminRepository.approveWithdrawal(
        requestId: requestId,
        uid: userId,
        amount: amount,
      );
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Duyệt yêu cầu rút tiền thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Duyệt yêu cầu thất bại: $e',
      );
    }
  }

  Future<void> rejectWithdrawal(String requestId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _adminRepository.rejectWithdrawal(requestId: requestId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Đã từ chối yêu cầu rút tiền!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Từ chối yêu cầu thất bại: $e',
      );
    }
  }

  Future<void> resetUserWallet(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _adminRepository.resetUserWallet(userId);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Khôi phục số dư ví thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Khôi phục số dư thất bại: $e',
      );
    }
  }

  Future<void> adminEditBalance(String userId, double newBalance) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _adminRepository.adminEditBalance(uid: userId, newBalance: newBalance);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Chỉnh sửa số dư ví thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Chỉnh sửa số dư thất bại: $e',
      );
    }
  }

  Future<void> toggleAdminStatus(String userId, bool isAdmin) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _adminRepository.toggleUserAdminStatus(userId, isAdmin);
      state = state.copyWith(
        isLoading: false,
        successMessage: isAdmin ? 'Đã cấp quyền Admin!' : 'Đã thu hồi quyền Admin!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Cập nhật quyền thất bại: $e',
      );
    }
  }

  Future<void> seedMockRequests(String userId, String displayName) async {
    try {
      await _adminRepository.seedMockRequests(userId, displayName);
      state = state.copyWith(
        successMessage: 'Đã seed yêu cầu rút tiền mẫu!',
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Seed dữ liệu mẫu thất bại: $e',
      );
    }
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    _walletsSub?.cancel();
    _requestsSub?.cancel();
    _logsSub?.cancel();
    super.dispose();
  }
}
