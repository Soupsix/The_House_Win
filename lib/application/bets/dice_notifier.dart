import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dice_state.dart';
import 'bet_state.dart';
import '../wallet/wallet_notifier.dart';
import '../wallet/wallet_state.dart';
import '../../data/firebase/firestore_service.dart';
import '../../data/firebase/betting_session_service.dart';
import '../../core/services/session_timer_service.dart';
import '../../data/local/database_helper.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/enums/bet_choice.dart';
import '../../domain/enums/bet_status.dart';
import '../../domain/enums/session_status.dart';

// Notifier quản lý các đơn đặt cược của mini-game Tài Xỉu
class DiceNotifier extends StateNotifier<DiceState> {
  final FirestoreService _firestoreService;
  final WalletNotifier _walletNotifier;
  final DatabaseHelper _dbHelper;
  final BettingSessionService _sessionService;
  final SessionTimerService _timerService;

  StreamSubscription? _activeSessionSub;
  StreamSubscription? _countdownSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _sessionBetsSub;

  DiceNotifier(
    this._firestoreService,
    this._walletNotifier,
    this._dbHelper,
    this._sessionService,
    this._timerService,
  ) : super(const DiceState());

  @override
  void dispose() {
    _activeSessionSub?.cancel();
    _countdownSub?.cancel();
    _statusSub?.cancel();
    _sessionBetsSub?.cancel();
    super.dispose();
  }

  // Khởi động lắng nghe active session và countdown từ SessionTimerService
  Future<void> initialize(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Lắng nghe đếm ngược từ timer service
    _countdownSub?.cancel();
    _countdownSub = _timerService.countdown.listen((seconds) {
      if (mounted) state = state.copyWith(countdown: seconds);
    });

    // Lắng nghe trạng thái phiên từ timer service
    _statusSub?.cancel();
    _statusSub = _timerService.sessionStatus.listen((status) {
      if (mounted) state = state.copyWith(sessionStatus: status);
    });

    // Lắng nghe phiên active từ Firestore
    _activeSessionSub?.cancel();
    _activeSessionSub = _sessionService.watchActiveSession().listen((session) {
      if (!mounted) return;
      state = state.copyWith(activeSession: session);
      if (session != null) {
        _subscribeToSessionBets(session.sessionId, userId);
      }
    });

    if (mounted) state = state.copyWith(isLoading: false);
  }

  // Lắng nghe cược của user trong phiên hiện tại
  void _subscribeToSessionBets(String sessionId, String userId) {
    _sessionBetsSub?.cancel();
    _sessionBetsSub = _sessionService.watchSessionBets(sessionId).listen((bets) {
      if (!mounted) return;
      final userSessionBets = bets.where((b) => b.userId == userId).toList();
      
      // Kiểm tra xem có cược nào vừa được kết toán không để trigger thông báo kết quả
      _checkAndNotifySettledBets(userSessionBets);

      state = state.copyWith(currentSessionBets: userSessionBets);
    });
  }

  // So sánh trạng thái cũ và mới để kích hoạt thông báo kết quả thắng/thua
  void _checkAndNotifySettledBets(List<BetModel> updatedBets) {
    for (final updated in updatedBets) {
      final previous = state.currentSessionBets.firstWhere(
        (b) => b.id == updated.id,
        orElse: () => updated.copyWith(status: BetStatus.pending),
      );

      if (previous.status == BetStatus.pending && updated.status != BetStatus.pending) {
        // Đã được giải quyết từ pending thành won/lost/push
        _onSessionSettled(updated);
      }
    }
  }

  // Xử lý khi đơn cược Tài Xỉu được kết toán
  void _onSessionSettled(BetModel bet) async {
    // 1. Tải lại ví để đồng bộ số dư mới
    await _walletNotifier.loadWallet(bet.userId);

    // 2. Lưu lịch sử vào SQLite local
    try {
      final db = await _dbHelper.database;
      await db.insert(
        'bet_history',
        bet.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {}

    // 3. Gửi thông báo kết quả lên UI qua successMessage
    if (bet.status == BetStatus.won) {
      final winAmount = _walletNotifier.state.transactionHistory.firstWhere(
        (t) => t.referenceId == bet.id,
        orElse: () => TransactionModel(
          id: '',
          userId: bet.userId,
          type: 'BET_WIN',
          amount: bet.amount * bet.oddsAtTime,
          referenceId: bet.id,
          createdAt: DateTime.now(),
        ),
      ).amount;
      if (mounted) {
        state = state.copyWith(
          successMessage: 'Chúc mừng! Bạn đã thắng $winAmount SC từ phiên #${bet.sessionNumber}',
        );
      }
    } else if (bet.status == BetStatus.lost) {
      if (mounted) {
        state = state.copyWith(
          errorMessage: 'Rất tiếc! Bạn đã thua đơn cược phiên #${bet.sessionNumber}',
        );
      }
    }
  }

  // Tạo draft cược Tài Xỉu
  void draftSessionBet(String choice, double amount) {
    state = state.copyWith(errorMessage: null, successMessage: null);

    if (amount <= 0) {
      state = state.copyWith(errorMessage: 'Số tiền đặt cược phải lớn hơn 0');
      return;
    }

    final availableBalance = _walletNotifier.state.availableBalance;
    if (amount > availableBalance) {
      state = state.copyWith(errorMessage: 'Số dư khả dụng trong ví không đủ');
      return;
    }

    final activeSession = state.activeSession;
    if (activeSession == null || activeSession.status != SessionStatus.open) {
      state = state.copyWith(errorMessage: 'Phiên cược đã khoá, không thể đặt cược');
      return;
    }

    final odds = choice == 'over' ? activeSession.oddsOver : activeSession.oddsUnder;

    state = state.copyWith(
      currentDraft: BetDraftModel(
        sessionId: activeSession.sessionId,
        choice: choice == 'over' ? BetChoice.over : BetChoice.under,
        amount: amount,
        oddsAtTime: odds,
        potentialPayout: amount * odds,
      ),
    );
  }

  // Xác nhận đặt đơn cược nháp thành cược chính thức
  Future<void> confirmBet(String uid) async {
    final draft = state.currentDraft;

    if (draft == null || draft.sessionId == null) {
      state = state.copyWith(errorMessage: 'Không có cược nháp nào để xác nhận');
      return;
    }

    if (state.isSubmitting) return;

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await _sessionService.placeBet(
        sessionId: draft.sessionId!,
        userId: uid,
        choice: draft.choice.name,
        amount: draft.amount,
        oddsAtTime: draft.oddsAtTime,
      );

      // Đồng bộ lại ví ảo sau khi cược thành công
      await _walletNotifier.loadWallet(uid);

      if (mounted) {
        state = state.copyWith(
          currentDraft: null,
          isSubmitting: false,
          successMessage: 'Đặt cược Tài Xỉu thành công!',
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: 'Xác nhận cược thất bại: $e',
        );
      }
    }
  }

  // Hủy bỏ đơn cược nháp hiện tại
  void cancelDraft() {
    state = state.copyWith(
      currentDraft: null,
      errorMessage: null,
      successMessage: null,
    );
  }

  // Tải thêm lịch sử cược Tài Xỉu
  Future<void> loadMoreHistory(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_sessionService.betCollection) // Sử dụng betCollection cấu hình của service
          .where('userId', isEqualTo: userId)
          .limit(100)
          .get();

      final allBets = snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();
      
      allBets.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      final settledBets = allBets.where((bet) => bet.status != BetStatus.pending).toList();

      if (mounted) {
        state = state.copyWith(
          settledBets: settledBets,
          isLoading: false,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Lỗi tải thêm lịch sử: $e',
        );
      }
    }
  }
}
