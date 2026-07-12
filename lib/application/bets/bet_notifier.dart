import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'bet_state.dart';
import '../wallet/wallet_notifier.dart';
import '../wallet/wallet_state.dart';
import '../matches/match_notifier.dart'; // để implement IBetsSettler
import '../../data/firebase/firestore_service.dart';
import '../../domain/enums/match_status.dart';
import '../../data/local/database_helper.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/enums/bet_choice.dart';
import '../../domain/enums/bet_status.dart';

// Notifier quản lý các đơn đặt cược bóng đá
class BetNotifier extends StateNotifier<BetState> implements IBetsSettler {
  final FirestoreService _firestoreService;
  final WalletNotifier _walletNotifier;
  final DatabaseHelper _dbHelper;

  StreamSubscription? _userPendingBetsSub;

  BetNotifier(
    this._firestoreService,
    this._walletNotifier,
    this._dbHelper,
  ) : super(const BetState());

  @override
  void dispose() {
    _userPendingBetsSub?.cancel();
    super.dispose();
  }

  Future<void> initialize(String userId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    // Tải cược cũ của bóng đá
    await loadBets(userId);

    // Lắng nghe cược pending của user cho bóng đá
    _userPendingBetsSub?.cancel();
    _userPendingBetsSub = FirebaseFirestore.instance
        .collection('bets')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: BetStatus.pending.name)
        .snapshots()
        .listen((snap) {
      final bets = snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();
      final footballPending = bets.where((b) => b.sessionId == null).toList();
      state = state.copyWith(pendingBets: footballPending);
    });

    state = state.copyWith(isLoading: false);
  }



  // Tạo draft cược bóng đá
  void draftBet(String matchId, BetChoice choice, double amount, double odds) {
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

    final potentialPayout = amount * odds;
    state = state.copyWith(
      currentDraft: BetDraftModel(
        matchId: matchId,
        choice: choice,
        amount: amount,
        oddsAtTime: odds,
        potentialPayout: potentialPayout,
      ),
    );
  }

  // Xác nhận đặt đơn cược nháp thành cược chính thức
  Future<void> confirmBet(String uid) async {
    final draft = state.currentDraft;

    if (draft == null) {
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
      if (draft.matchId != null) {
        // --- XỬ LÝ CƯỢC BÓNG ĐÁ ---
        final matchDoc = await _firestoreService.getMatchDocument(draft.matchId!);
        if (!matchDoc.exists || matchDoc.data() == null) {
          throw Exception('Trận đấu không tồn tại');
        }

        final matchData = matchDoc.data()!;
        final isBettingLocked = matchData['isBettingLocked'] as bool? ?? false;
        final matchStatus = matchData['status']?.toString() ?? 'scheduled';

        if (isBettingLocked) {
          throw Exception('Trận đấu đã bị Admin khóa cược.');
        }

        if (matchStatus == 'finished') {
          throw Exception('Trận đấu đã kết thúc.');
        }

        final betId = 'bet_${DateTime.now().millisecondsSinceEpoch}_$uid';
        final homeTeam = matchData['homeTeam']?.toString() ?? '';
        final awayTeam = matchData['awayTeam']?.toString() ?? '';

        // Trừ tiền thông qua walletNotifier
        await _walletNotifier.deductBet(uid, draft.amount, betId);

        if (_walletNotifier.state.errorMessage != null) {
          throw Exception(_walletNotifier.state.errorMessage);
        }

        // Lưu cược vào Firestore
        await _firestoreService.saveBetInFirestore(
          betId,
          {
            'userId': uid,
            'matchId': draft.matchId,
            'homeTeam': homeTeam,
            'awayTeam': awayTeam,
            'choice': draft.choice.name,
            'amount': draft.amount,
            'oddsAtTime': draft.oddsAtTime,
            'payout': 0.0,
            'status': BetStatus.pending.name,
            'createdAt': FieldValue.serverTimestamp(),
          },
        );

        state = state.copyWith(
          currentDraft: null,
          isSubmitting: false,
          successMessage: 'Đặt cược bóng đá thành công!',
        );

        await loadBets(uid);
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Xác nhận cược thất bại: $e',
      );
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

  // Tải danh sách các cược pending và cược đã giải quyết của người dùng
  Future<void> loadBets(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // Dùng truy vấn đơn giản chỉ lọc userId để không yêu cầu composite index
      final snap = await FirebaseFirestore.instance
          .collection('bets')
          .where('userId', isEqualTo: uid)
          .limit(100)
          .get();

      final allBets = snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();

      // Sắp xếp theo thời gian tạo giảm dần trong bộ nhớ
      allBets.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });

      final pendingBets = allBets.where((bet) => bet.status == BetStatus.pending).toList();
      final settledBets = allBets.where((bet) => bet.status != BetStatus.pending).toList();

      state = state.copyWith(
        pendingBets: pendingBets,
        settledBets: settledBets,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi tải lịch sử cược: $e',
      );
    }
  }



  // Callback được MatchNotifier trigger khi trận đấu bóng đá có kết quả
  @override
  Future<void> onMatchSettled(String matchId, MatchResult result) async {
    try {
      final pendingBetsSnap =
          await _firestoreService.getPendingBetsForMatch(matchId);
      final pendingBetsList = pendingBetsSnap.docs
          .map((doc) => BetModel.fromFirestore(doc))
          .toList();

      final settledAt = DateTime.now();

      for (var bet in pendingBetsList) {
        BetStatus status = BetStatus.lost;
        double payout = 0.0;

        if (bet.choice == BetChoice.over) {
          if (result == MatchResult.over) {
            status = BetStatus.won;
            payout = bet.amount * bet.oddsAtTime;
          } else if (result == MatchResult.push) {
            status = BetStatus.push;
            payout = bet.amount;
          }
        } else if (bet.choice == BetChoice.under) {
          if (result == MatchResult.under) {
            status = BetStatus.won;
            payout = bet.amount * bet.oddsAtTime;
          } else if (result == MatchResult.push) {
            status = BetStatus.push;
            payout = bet.amount;
          }
        }

        final isWinOrPush =
            (status == BetStatus.won || status == BetStatus.push);

        await _walletNotifier.settleBet(
          bet.userId,
          bet.amount,
          payout,
          bet.id,
          isWinOrPush,
        );

        await _firestoreService.updateBetStatus(
            bet.id, status.name, payout, settledAt);

        final settledBet = bet.copyWith(
          status: status,
          payout: payout,
          settledAt: settledAt,
        );
        final db = await _dbHelper.database;
        await db.insert(
          'bet_history',
          settledBet.toSQLite(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await loadBets(bet.userId);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi giải quyết cược bóng đá: $e',
      );
    }
  }

  // Admin cưỡng chế thay đổi kết quả của một đơn đặt cược bóng đá
  Future<void> adminOverrideBet(String betId, BetStatus newStatus) async {
    state = state.copyWith(
        isLoading: true, errorMessage: null, successMessage: null);
    try {
      await _firestoreService.writeAdminLog('OVERRIDE_BET_STATUS', {
        'betId': betId,
        'status': newStatus.name,
      });

      final betDoc = await _firestoreService.getBetDocument(betId);
      if (!betDoc.exists) {
        throw Exception("Không tìm thấy đơn cược");
      }

      final betData = betDoc.data()!;
      final oldStatus = betData['status'] as String? ?? 'pending';
      final userId = betData['userId'] as String? ?? '';
      final amount = (betData['amount'] as num?)?.toDouble() ?? 0.0;
      final oddsAtTime = (betData['oddsAtTime'] as num?)?.toDouble() ?? 0.0;
      final homeTeam = betData['homeTeam'] as String? ?? '';
      final awayTeam = betData['awayTeam'] as String? ?? '';
      final matchId = betData['matchId'] as String? ?? '';
      final choiceString = betData['choice'] as String? ?? 'over';
      final choice = BetChoice.values.firstWhere((e) => e.name == choiceString,
          orElse: () => BetChoice.over);

      double payout = 0.0;
      if (newStatus == BetStatus.won) {
        payout = amount * oddsAtTime;
      } else if (newStatus == BetStatus.push) {
        payout = amount;
      }

      final isWinOrPush =
          (newStatus == BetStatus.won || newStatus == BetStatus.push);

      await _walletNotifier.settleBet(
        userId,
        amount,
        payout,
        betId,
        isWinOrPush,
      );

      final settledAt = DateTime.now();
      await _firestoreService.updateBetStatus(
          betId, newStatus.name, payout, settledAt);

      final settledBet = BetModel(
        id: betId,
        userId: userId,
        matchId: matchId,
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        choice: choice,
        amount: amount,
        oddsAtTime: oddsAtTime,
        payout: payout,
        status: newStatus,
        createdAt:
            (betData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        settledAt: settledAt,
      );

      final db = await _dbHelper.database;
      await db.insert(
        'bet_history',
        settledBet.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await loadBets(userId);

      state = state.copyWith(
        isLoading: false,
        successMessage: 'Cưỡng chế kết quả cược thành công!',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Lỗi admin cưỡng chế kết quả cược: $e',
      );
    }
  }
}
