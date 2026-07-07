import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bet_state.dart';
import '../wallet/wallet_notifier.dart';
import '../wallet/wallet_state.dart'; // để truy cập getter availableBalance
import '../matches/match_notifier.dart'; // để implement IBetsSettler
import '../../data/firebase/firestore_service.dart';
import '../../data/local/database_helper.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/enums/bet_choice.dart';
import '../../domain/enums/bet_status.dart';
import '../../domain/enums/match_status.dart';

// Notifier quản lý các đơn đặt cược của người dùng
class BetNotifier extends StateNotifier<BetState> implements IBetsSettler {
  final FirestoreService _firestoreService;
  final WalletNotifier _walletNotifier;
  final DatabaseHelper _dbHelper;

  BetNotifier(
    this._firestoreService,
    this._walletNotifier,
    this._dbHelper,
  ) : super(const BetState());

  // Khởi tạo cược nháp trong bộ nhớ tạm (chưa lưu Firestore)
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

    state = state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null);
    try {
      final betId = 'bet_${DateTime.now().millisecondsSinceEpoch}_$uid';

      // 1. Gọi WalletNotifier để trừ tiền và khóa tiền cược
      await _walletNotifier.deductBet(uid, draft.amount, betId);

      // 2. Đọc thông tin trận đấu để điền homeTeam, awayTeam
      final matchDoc = await _firestoreService.getMatchDocument(draft.matchId);
      if (!matchDoc.exists) {
        throw Exception("Trận đấu không tồn tại");
      }
      final matchData = matchDoc.data()!;
      final homeTeam = matchData['homeTeam'] as String? ?? '';
      final awayTeam = matchData['awayTeam'] as String? ?? '';

      // 3. Ghi bet document mới vào Firestore collection bets
      await _firestoreService.saveBetInFirestore(betId, {
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
      });

      state = state.copyWith(
        currentDraft: null,
        isSubmitting: false,
        successMessage: 'Đặt cược thành công!',
      );

      // Tải lại danh sách cược
      await loadBets(uid);
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Xác nhận cược thất bại: $e',
      );
    }
  }

  // Hủy bỏ đơn cược nháp hiện tại
  void cancelDraft() {
    state = state.copyWith(currentDraft: null, errorMessage: null, successMessage: null);
  }

  // Tải danh sách các cược pending và cược đã giải quyết của người dùng
  Future<void> loadBets(String uid) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final pendingSnap = await _firestoreService.getPendingBets(uid);
      final settledSnap = await _firestoreService.getSettledBetsLimit50(uid);

      final pendingBets = pendingSnap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();
      final settledBets = settledSnap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();

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

  // Callback được MatchNotifier trigger khi trận đấu có kết quả chính thức
  @override
  Future<void> onMatchSettled(String matchId, MatchResult result) async {
    try {
      // Lấy toàn bộ cược đang chờ kết quả của trận đấu này từ Firestore
      final pendingBetsSnap = await _firestoreService.getPendingBetsForMatch(matchId);
      final pendingBetsList = pendingBetsSnap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();

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

        final isWinOrPush = (status == BetStatus.won || status == BetStatus.push);

        // 1. Gọi WalletNotifier để thanh toán tiền thắng/hoàn cược
        await _walletNotifier.settleBet(
          bet.userId,
          bet.amount,
          payout,
          bet.id,
          isWinOrPush,
        );

        // 2. Cập nhật trạng thái cược trong Firestore
        await _firestoreService.updateBetStatus(bet.id, status.name, payout, settledAt);

        // 3. Lưu cược đã thanh toán vào SQLite local
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

        // Đồng bộ lại danh sách cược cho người dùng hiện tại
        await loadBets(bet.userId);
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Lỗi giải quyết cược khi trận đấu kết thúc: $e',
      );
    }
  }

  // Admin cưỡng chế thay đổi kết quả của một đơn đặt cược
  Future<void> adminOverrideBet(String betId, BetStatus newStatus) async {
    state = state.copyWith(isLoading: true, errorMessage: null, successMessage: null);
    try {
      // 1. Ghi log hành động của admin
      await _firestoreService.writeAdminLog('OVERRIDE_BET_STATUS', {
        'betId': betId,
        'status': newStatus.name,
      });

      // 2. Lấy dữ liệu cược gốc để tính toán
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
      final choice = BetChoice.values.firstWhere((e) => e.name == choiceString, orElse: () => BetChoice.over);

      // Tính payout mới
      double payout = 0.0;
      if (newStatus == BetStatus.won) {
        payout = amount * oddsAtTime;
      } else if (newStatus == BetStatus.push) {
        payout = amount;
      }

      final isWinOrPush = (newStatus == BetStatus.won || newStatus == BetStatus.push);

      // 3. Cập nhật ví ảo dựa trên trạng thái cũ
      if (oldStatus == 'pending') {
        await _walletNotifier.settleBet(
          userId,
          amount,
          payout,
          betId,
          isWinOrPush,
        );
      } else {
        // Nếu cược đã settle rồi, ta settle lại với giá trị mới (WalletNotifier.settleBet xử lý)
        await _walletNotifier.settleBet(
          userId,
          amount,
          payout,
          betId,
          isWinOrPush,
        );
      }

      // 4. Cập nhật Firestore status của cược
      final settledAt = DateTime.now();
      await _firestoreService.updateBetStatus(betId, newStatus.name, payout, settledAt);

      // 5. Cập nhật SQLite
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
        createdAt: (betData['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        settledAt: settledAt,
      );

      final db = await _dbHelper.database;
      await db.insert(
        'bet_history',
        settledBet.toSQLite(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 6. Đồng bộ lại danh sách cược cho người chơi
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
