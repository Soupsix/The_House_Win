import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/i_admin_repository.dart';
import 'admin_state.dart';

class AdminNotifier extends StateNotifier<AdminState> {
  final IAdminRepository _adminRepository;

  StreamSubscription? _usersSub;
  StreamSubscription? _walletsSub;
  StreamSubscription? _requestsSub;
  StreamSubscription? _logsSub;
  StreamSubscription? _matchesSub;
  StreamSubscription? _settingsSub;

  AdminNotifier(this._adminRepository) : super(const AdminState());

  void initialize({String? adminId}) {
    _cancelSubscriptions();

    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    _usersSub = _adminRepository.watchAllUsers().listen(
      (usersList) {
        state = state.copyWith(
          users: usersList,
          isLoading: false,
        );
      },
      onError: (Object error) {
        _setError(
          'Lỗi tải danh sách người dùng: $error',
        );
      },
    );

    _walletsSub = _adminRepository.watchAllWallets().listen(
      (walletsList) {
        final balances = <String, double>{};

        for (final wallet in walletsList) {
          final userId = wallet['userId']?.toString() ?? '';

          final rawBalance = wallet['balance'];
          final balance = rawBalance is num ? rawBalance.toDouble() : 0.0;

          if (userId.isNotEmpty) {
            balances[userId] = balance;
          }
        }

        state = state.copyWith(
          userBalances: balances,
        );
      },
      onError: (Object error) {
        _setError(
          'Lỗi tải dữ liệu ví: $error',
        );
      },
    );

    _requestsSub = _adminRepository.watchWithdrawalRequests().listen(
      (requests) {
        state = state.copyWith(
          withdrawalRequests: requests,
        );
      },
      onError: (Object error) {
        _setError(
          'Lỗi tải yêu cầu rút tiền: $error',
        );
      },
    );

    _logsSub = _adminRepository.watchAdminLogs().listen(
      (logs) {
        state = state.copyWith(
          adminLogs: logs,
        );
      },
      onError: (Object error) {
        _setError(
          'Lỗi tải log Admin: $error',
        );
      },
    );
    _matchesSub = _adminRepository.watchAdminMatches().listen(
      (matches) {
        state = state.copyWith(
          matches: matches,
          isLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi tải danh sách trận đấu: $error',
        );
      },
    );

    _matchesSub = _adminRepository.watchAllMatches().listen(
      (matches) {
        state = state.copyWith(
          matches: matches,
        );
      },
      onError: (Object error) {
        _setError(
          'Lỗi tải danh sách trận đấu: $error',
        );
      },
    );

    if (adminId != null && adminId.trim().isNotEmpty) {
      _settingsSub = _adminRepository.watchAdminSettings(adminId).listen(
        (settings) {
          state = state.copyWith(
            adminSettings: settings,
          );
        },
        onError: (Object error) {
          _setError(
            'Lỗi tải cấu hình Admin: $error',
          );
        },
      );
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(
      searchQuery: query,
    );
  }

  void clearMessage() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
  }

  Future<void> approveWithdrawal(
    String requestId,
    String userId,
    double amount,
  ) async {
    await _runAction(
      action: () => _adminRepository.approveWithdrawal(
        requestId: requestId,
        uid: userId,
        amount: amount,
      ),
      successMessage: 'Duyệt yêu cầu rút tiền thành công!',
      errorPrefix: 'Duyệt yêu cầu thất bại',
    );
  }

  Future<void> rejectWithdrawal(
    String requestId,
  ) async {
    await _runAction(
      action: () => _adminRepository.rejectWithdrawal(
        requestId: requestId,
      ),
      successMessage: 'Đã từ chối yêu cầu rút tiền!',
      errorPrefix: 'Từ chối yêu cầu thất bại',
    );
  }

  Future<void> resetUserWallet(
    String userId,
  ) async {
    await _runAction(
      action: () => _adminRepository.resetUserWallet(userId),
      successMessage: 'Khôi phục số dư ví thành công!',
      errorPrefix: 'Khôi phục số dư thất bại',
    );
  }

  Future<void> adminEditBalance(
    String userId,
    double newBalance,
  ) async {
    if (newBalance < 0) {
      _setError(
        'Số dư không được nhỏ hơn 0.',
      );
      return;
    }

    await _runAction(
      action: () => _adminRepository.adminEditBalance(
        uid: userId,
        newBalance: newBalance,
      ),
      successMessage: 'Chỉnh sửa số dư ví thành công!',
      errorPrefix: 'Chỉnh sửa số dư thất bại',
    );
  }

  Future<void> toggleAdminStatus(
    String userId,
    bool isAdmin,
  ) async {
    await _runAction(
      action: () => _adminRepository.toggleUserAdminStatus(
        userId,
        isAdmin,
      ),
      successMessage:
          isAdmin ? 'Đã cấp quyền Admin!' : 'Đã thu hồi quyền Admin!',
      errorPrefix: 'Cập nhật quyền thất bại',
    );
  }

  Future<void> seedMockRequests(
    String userId,
    String displayName,
  ) async {
    await _runAction(
      action: () => _adminRepository.seedMockRequests(
        userId,
        displayName,
      ),
      successMessage: 'Đã tạo yêu cầu rút tiền mẫu!',
      errorPrefix: 'Tạo dữ liệu mẫu thất bại',
    );
  }

  // 11.3 - Sửa tỷ lệ kèo
  Future<void> updateMatchOdds({
    required String matchId,
    required double overOdds,
    required double underOdds,
    required double line,
  }) async {
    if (overOdds <= 0 || underOdds <= 0 || line < 0) {
      _setError(
        'Tỷ lệ kèo phải lớn hơn 0 và mốc kèo không được âm.',
      );
      return;
    }

    await _runAction(
      action: () => _adminRepository.updateMatchOdds(
        matchId: matchId,
        overOdds: overOdds,
        underOdds: underOdds,
        line: line,
      ),
      successMessage: 'Cập nhật tỷ lệ kèo thành công!',
      errorPrefix: 'Cập nhật tỷ lệ kèo thất bại',
    );
  }

  // 11.4 - Sửa kết quả Tài/Xỉu
  Future<void> forceMatchResult({
    required String matchId,
    required String result,
  }) async {
    const validResults = {
      'over',
      'under',
      'draw',
    };

    final normalizedResult = result.trim().toLowerCase();

    if (!validResults.contains(normalizedResult)) {
      _setError(
        'Kết quả phải là over, under hoặc draw.',
      );
      return;
    }

    await _runAction(
      action: () => _adminRepository.forceMatchResult(
        matchId: matchId,
        result: normalizedResult,
      ),
      successMessage: 'Cập nhật kết quả trận đấu thành công!',
      errorPrefix: 'Cập nhật kết quả thất bại',
    );
  }

  // 11.6 - Khóa hoặc mở cược trận
  Future<void> updateMatchBettingLock({
    required String matchId,
    required bool isLocked,
  }) async {
    await _runAction(
      action: () => _adminRepository.updateMatchBettingLock(
        matchId: matchId,
        isLocked: isLocked,
      ),
      successMessage:
          isLocked ? 'Đã khóa cược trận đấu!' : 'Đã mở cược trận đấu!',
      errorPrefix: 'Cập nhật trạng thái cược thất bại',
    );
  }

  // 11.8 - Cấu hình anti-gambling
  Future<void> updateAntiGamblingSettings({
    required String adminId,
    required double warningLossThreshold,
    required double criticalLossThreshold,
    required int maximumBetsPerDay,
    required int breakMinutes,
    required bool enabled,
  }) async {
    if (warningLossThreshold < 0 ||
        criticalLossThreshold < 0 ||
        maximumBetsPerDay < 1 ||
        breakMinutes < 1) {
      _setError(
        'Các giá trị cấu hình anti-gambling không hợp lệ.',
      );
      return;
    }

    if (criticalLossThreshold < warningLossThreshold) {
      _setError(
        'Ngưỡng nguy hiểm phải lớn hơn hoặc bằng ngưỡng cảnh báo.',
      );
      return;
    }

    final settings = <String, dynamic>{
      'enabled': enabled,
      'warningLossThreshold': warningLossThreshold,
      'criticalLossThreshold': criticalLossThreshold,
      'maximumBetsPerDay': maximumBetsPerDay,
      'breakMinutes': breakMinutes,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _runAction(
      action: () => _adminRepository.updateAntiGamblingSettings(
        adminId: adminId,
        settings: settings,
      ),
      successMessage: 'Lưu cấu hình anti-gambling thành công!',
      errorPrefix: 'Lưu cấu hình anti-gambling thất bại',
    );
  }

  // 11.9 - Nội dung giáo dục
  Future<void> updateEducationContent({
    required String adminId,
    required String title,
    required String description,
    required String videoUrl,
    required bool enabled,
  }) async {
    if (title.trim().isEmpty) {
      _setError(
        'Tiêu đề nội dung giáo dục không được để trống.',
      );
      return;
    }

    if (description.trim().isEmpty) {
      _setError(
        'Nội dung giáo dục không được để trống.',
      );
      return;
    }

    final content = <String, dynamic>{
      'enabled': enabled,
      'title': title.trim(),
      'description': description.trim(),
      'videoUrl': videoUrl.trim(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    await _runAction(
      action: () => _adminRepository.updateEducationContent(
        adminId: adminId,
        content: content,
      ),
      successMessage: 'Lưu nội dung giáo dục thành công!',
      errorPrefix: 'Lưu nội dung giáo dục thất bại',
    );
  }

  Future<void> _runAction({
    required Future<void> Function() action,
    required String successMessage,
    required String errorPrefix,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );

    try {
      await action();

      state = state.copyWith(
        isLoading: false,
        successMessage: successMessage,
        clearErrorMessage: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '$errorPrefix: $error',
        clearSuccessMessage: true,
      );
    }
  }

  void _setError(String message) {
    state = state.copyWith(
      isLoading: false,
      errorMessage: message,
      clearSuccessMessage: true,
    );
  }

  void _cancelSubscriptions() {
    _usersSub?.cancel();
    _walletsSub?.cancel();
    _requestsSub?.cancel();
    _logsSub?.cancel();
    _matchesSub?.cancel();
    _settingsSub?.cancel();
    _matchesSub?.cancel();
  }

  @override
  void dispose() {
    _cancelSubscriptions();
    _matchesSub?.cancel();
    super.dispose();
  }
}
