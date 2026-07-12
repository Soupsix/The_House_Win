import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/enums/bet_status.dart';
import '../../domain/enums/bet_choice.dart';

// Service giao tiếp Firebase để quản lý các phiên cược Tài Xỉu
class BettingSessionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Thời gian tối thiểu (giây) giữa khi phiên kết toán và khi phiên mới được mở
  static const int postSettleCooldown = 12;

  // Lấy phiên gần nhất bất kể trạng thái (để tính cooldown)
  Future<BettingSessionModel?> getLatestSession() async {
    final snap = await _firestore.collection('betting_sessions')
        .orderBy('sessionNumber', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return BettingSessionModel.fromFirestore(snap.docs.first);
  }

  // Tạo phiên cược mới với số thứ tự tăng dần bằng transaction
  Future<BettingSessionModel> createSession() async {
    final docRef = _firestore.collection('betting_sessions').doc();
    return await _firestore.runTransaction((transaction) async {
      final query = await _firestore.collection('betting_sessions')
          .orderBy('sessionNumber', descending: true)
          .limit(1)
          .get();

      int nextNumber = 1;
      if (query.docs.isNotEmpty) {
        final latestDoc = query.docs.first;
        final latestStatus = latestDoc.data()['status'] as String? ?? 'settled';
        
        // Nếu phiên mới nhất chưa được kết toán và chưa quá hạn (>90s), trả về luôn phiên đó để dùng tiếp
        final startedAtTimestamp = latestDoc.data()['startedAt'] as Timestamp?;
        final startedAt = startedAtTimestamp?.toDate() ?? DateTime.now();
        final isStale = DateTime.now().difference(startedAt).inSeconds > 90;

        if (latestStatus != 'settled' && !isStale) {
          return BettingSessionModel.fromFirestore(latestDoc);
        }

        // Kiểm tra cooldown 12 giây sau khi phiên kết toán
        if (latestStatus == 'settled') {
          final settledAtTs = latestDoc.data()['settledAt'] as Timestamp?;
          if (settledAtTs != null) {
            final settledAt = settledAtTs.toDate();
            final secondsSinceSettle = DateTime.now().difference(settledAt).inSeconds;
            if (secondsSinceSettle < postSettleCooldown) {
              throw Exception(
                'Cooldown: phiên mới chỉ được mở sau $postSettleCooldown giây kể từ khi phiên trước kết toán'
              );
            }
          }
        }

        nextNumber = (latestDoc.data()['sessionNumber'] as int? ?? 0) + 1;
      }

      final newSession = BettingSessionModel(
        sessionId: docRef.id,
        sessionNumber: nextNumber,
        status: SessionStatus.open,
        startedAt: DateTime.now(),
        oddsOver: 1.85,
        oddsUnder: 1.95,
        overUnderLine: 2.5,
      );

      transaction.set(docRef, newSession.toFirestore());
      return newSession;
    });
  }

  // Lắng nghe realtime thông tin phiên cược đang hoạt động
  Stream<BettingSessionModel?> watchActiveSession() {
    return _firestore.collection('betting_sessions')
        .orderBy('sessionNumber', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) return null;
          final session = BettingSessionModel.fromFirestore(snapshot.docs.first);
          if (session.status == SessionStatus.settled) return null;
          return session;
        });
  }

  // Lắng nghe realtime danh sách cược của một phiên
  Stream<List<BetModel>> watchSessionBets(String sessionId) {
    return _firestore.collection('bets')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList());
  }

  // Cập nhật trạng thái của phiên cược
  Future<void> updateSessionStatus(String sessionId, SessionStatus status) async {
    final Map<String, dynamic> updateData = {
      'status': status.name,
    };
    if (status == SessionStatus.locked) {
      updateData['lockedAt'] = FieldValue.serverTimestamp();
    } else if (status == SessionStatus.settled) {
      updateData['settledAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('betting_sessions').doc(sessionId).update(updateData);
  }

  // Kết toán phiên cược, phân chia thắng thua và cập nhật số dư ví bằng transaction
  Future<void> settleSession({
    required String sessionId,
    required String result,
    required bool isAdminOverride,
    int dice1 = 0,
    int dice2 = 0,
    int dice3 = 0,
  }) async {
    final sessionRef = _firestore.collection('betting_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) return;

      final currentStatus = sessionSnap.data()?['status'] as String? ?? 'open';
      if (currentStatus == 'settled') return;

      final dbIsAdminOverride = sessionSnap.data()?['isAdminOverride'] as bool? ?? false;
      final finalResult = dbIsAdminOverride
          ? (sessionSnap.data()?['result'] as String? ?? result)
          : result;

      // 1. Tìm tất cả các cược đang chờ của phiên này
      final query = await _firestore.collection('bets')
          .where('sessionId', isEqualTo: sessionId)
          .where('status', isEqualTo: 'pending')
          .get();

      final bets = query.docs;
      final userIds = bets.map((d) => d.data()['userId'] as String).toSet().toList();

      // 2. Đọc toàn bộ ví liên quan (phải làm trước các thao tác write)
      final walletMap = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final uid in userIds) {
        final walletRef = _firestore.collection('wallets').doc(uid);
        walletMap[uid] = await transaction.get(walletRef);
      }

      // 3. Cập nhật phiên cược
      transaction.update(sessionRef, {
        'status': SessionStatus.settled.name,
        'settledAt': FieldValue.serverTimestamp(),
        'result': finalResult,
        'isAdminOverride': dbIsAdminOverride || isAdminOverride,
        'dice1': dice1,
        'dice2': dice2,
        'dice3': dice3,
      });

      // 4. Giải quyết từng đơn cược và hoàn tiền thắng
      for (final betDoc in bets) {
        final betRef = betDoc.reference;
        final betData = betDoc.data();
        final uid = betData['userId'] as String;
        final choiceStr = betData['choice'] as String;
        final amount = (betData['amount'] as num).toDouble();
        final oddsAtTime = (betData['oddsAtTime'] as num).toDouble();

        final isWin = choiceStr == finalResult;
        final payout = isWin ? (amount * oddsAtTime) : 0.0;
        final betStatus = isWin ? BetStatus.won : BetStatus.lost;

        transaction.update(betRef, {
          'status': betStatus.name,
          'payout': payout,
          'settledAt': FieldValue.serverTimestamp(),
        });

        final walletSnap = walletMap[uid];
        if (walletSnap != null && walletSnap.exists) {
          final walletData = walletSnap.data()!;
          final balance = (walletData['balance'] as num?)?.toDouble() ?? 0.0;
          final lockedAmount = (walletData['lockedAmount'] as num?)?.toDouble() ?? 0.0;

          // Mở khóa số tiền đã lock khi đặt cược
          final nextLockedAmount = (lockedAmount - amount < 0) ? 0.0 : lockedAmount - amount;
          // Thắng: cộng payout (gồm cả vốn + lời) vào balance
          // Thua: trừ số tiền đã đặt cược khỏi balance (thực tế mới mất tiền)
          final nextBalance = isWin ? (balance + payout) : (balance - amount);

          transaction.update(walletSnap.reference, {
            'balance': nextBalance,
            'lockedAmount': nextLockedAmount,
          });

          final txRef = _firestore.collection('transactions').doc();
          transaction.set(txRef, {
            'userId': uid,
            'type': isWin ? 'BET_WIN' : 'BET_LOSE',
            'amount': isWin ? payout : amount,
            'referenceId': betDoc.id,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  // Admin override cưỡng chế kết quả phiên cược
  Future<void> adminOverrideResult({
    required String sessionId,
    required String result,
    required String adminId,
  }) async {
    final sessionRef = _firestore.collection('betting_sessions').doc(sessionId);
    await _firestore.runTransaction((transaction) async {
      final snap = await transaction.get(sessionRef);
      if (!snap.exists) throw Exception("Phiên cược không tồn tại");

      final status = snap.data()?['status'] as String? ?? 'open';
      if (status == 'settled') {
        throw Exception("Không thể thay đổi kết quả của phiên đã kết toán");
      }

      transaction.update(sessionRef, {
        'result': result,
        'isAdminOverride': true,
      });

      final logRef = _firestore.collection('admin_logs').doc();
      transaction.set(logRef, {
        'adminId': adminId,
        'action': 'ADMIN_OVERRIDE_SESSION',
        'timestamp': FieldValue.serverTimestamp(),
        'details': {
          'sessionId': sessionId,
          'result': result,
        },
      });
    });
  }

  // Người chơi thực hiện đặt cược vào phiên cược bằng transaction
  Future<BetModel> placeBet({
    required String sessionId,
    required String userId,
    required String choice,
    required double amount,
    required double oddsAtTime,
  }) async {
    final sessionRef = _firestore.collection('betting_sessions').doc(sessionId);
    final walletRef = _firestore.collection('wallets').doc(userId);
    final betRef = _firestore.collection('bets').doc();
    final txRef = _firestore.collection('transactions').doc();

    return await _firestore.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) throw Exception("Phiên cược không tồn tại");

      final sessionNumber = sessionSnap.data()?['sessionNumber'] as int? ?? 0;
      final status = sessionSnap.data()?['status'] as String? ?? 'open';
      if (status != 'open') {
        throw Exception("Phiên cược đã khoá, không thể đặt cược");
      }

      final walletSnap = await transaction.get(walletRef);
      if (!walletSnap.exists) throw Exception("Ví ảo không tồn tại");

      final walletData = walletSnap.data()!;
      final balance = (walletData['balance'] as num?)?.toDouble() ?? 0.0;
      final lockedAmount = (walletData['lockedAmount'] as num?)?.toDouble() ?? 0.0;
      final availableBalance = balance - lockedAmount;

      if (availableBalance < amount) {
        throw Exception("Số dư khả dụng không đủ");
      }

      // Chỉ khóa tiền (tăng lockedAmount), không trừ balance ngay
      // → availableBalance = balance - lockedAmount hiển thị đúng (chỉ trừ 1 lần)
      transaction.update(walletRef, {
        'lockedAmount': lockedAmount + amount,
      });

      final choiceEnum = choice == 'over' ? BetChoice.over : BetChoice.under;
      final bet = BetModel(
        id: betRef.id,
        userId: userId,
        sessionId: sessionId,
        sessionNumber: sessionNumber,
        choice: choiceEnum,
        amount: amount,
        oddsAtTime: oddsAtTime,
        payout: 0.0,
        status: BetStatus.pending,
        createdAt: DateTime.now(),
      );

      transaction.set(betRef, bet.toFirestore());

      transaction.set(txRef, {
        'userId': userId,
        'type': 'BET_LOCKED',
        'amount': amount,
        'referenceId': betRef.id,
        'createdAt': FieldValue.serverTimestamp(),
      });

      final fieldToUpdate = choice == 'over' ? 'totalOverBets' : 'totalUnderBets';
      final currentTotal = (sessionSnap.data()?[fieldToUpdate] as num?)?.toDouble() ?? 0.0;
      transaction.update(sessionRef, {
        fieldToUpdate: currentTotal + amount,
      });

      return bet;
    });
  }

  // Tải lịch sử cược Tài Xỉu đã giải quyết của user (phân trang)
  Future<List<BetModel>> getUserBetHistory(
    String userId, {
    DocumentSnapshot? lastDoc,
  }) async {
    Query query = _firestore.collection('bets')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['won', 'lost', 'push'])
        .orderBy('createdAt', descending: true)
        .limit(20);

    if (lastDoc != null) {
      query = query.startAfterDocument(lastDoc);
    }

    final snap = await query.get();
    return snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList();
  }

  // Lắng nghe các đơn cược đang chờ giải quyết của người dùng
  Stream<List<BetModel>> watchUserPendingBets(String userId) {
    return _firestore.collection('bets')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snap) => snap.docs.map((doc) => BetModel.fromFirestore(doc)).toList());
  }

  // Admin cập nhật kèo tài xỉu (tỷ lệ odds & dòng cược) của phiên đang hoạt động
  Future<void> updateSessionOdds({
    required String sessionId,
    required double oddsOver,
    required double oddsUnder,
    required double overUnderLine,
  }) async {
    await _firestore.collection('betting_sessions').doc(sessionId).update({
      'oddsOver': oddsOver,
      'oddsUnder': oddsUnder,
      'overUnderLine': overUnderLine,
    });
  }

  // 3.6 Admin sửa kết quả đơn cược thủ công và tự động điều chỉnh ví người chơi
  Future<void> adminUpdateBetStatus({
    required String betId,
    required String newStatus,
  }) async {
    final betRef = _firestore.collection('bets').doc(betId);
    
    await _firestore.runTransaction((transaction) async {
      final betSnap = await transaction.get(betRef);
      if (!betSnap.exists) throw Exception("Đơn cược không tồn tại");
      
      final oldStatus = betSnap.data()?['status'] as String? ?? 'pending';
      if (oldStatus == newStatus) return;
      
      final userId = betSnap.data()?['userId'] as String? ?? '';
      final amount = (betSnap.data()?['amount'] as num? ?? 0).toDouble();
      final odds = (betSnap.data()?['oddsAtTime'] as num? ?? 1.0).toDouble();
      
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletSnap = await transaction.get(walletRef);
      if (!walletSnap.exists) throw Exception("Ví người dùng không tồn tại");
      
      final currentBalance = (walletSnap.data()?['balance'] as num? ?? 0).toDouble();
      double balanceChange = 0.0;
      
      if ((oldStatus == 'pending' || oldStatus == 'lost' || oldStatus == 'push') && newStatus == 'won') {
        balanceChange = amount * odds;
      } else if (oldStatus == 'won' && (newStatus == 'lost' || newStatus == 'pending' || newStatus == 'push')) {
        balanceChange = -(amount * odds);
      } else if ((oldStatus == 'pending' || oldStatus == 'lost') && newStatus == 'push') {
        balanceChange = amount;
      } else if (oldStatus == 'push' && (newStatus == 'lost' || newStatus == 'pending')) {
        balanceChange = -amount;
      }
      
      transaction.update(betRef, {'status': newStatus});
      
      if (balanceChange != 0.0) {
        transaction.update(walletRef, {'balance': currentBalance + balanceChange});
        
        final txRef = _firestore.collection('transactions').doc();
        transaction.set(txRef, {
          'id': txRef.id,
          'userId': userId,
          'amount': balanceChange,
          'type': balanceChange > 0 ? 'admin_win_adjustment' : 'admin_loss_adjustment',
          'description': 'Admin điều chỉnh đơn cược $betId sang $newStatus',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // 3.6 Admin sửa kết quả phiên cược (Tài/Xỉu) và tự động tính lại toàn bộ cược trong phiên
  Future<void> adminOverrideSettleResult({
    required String sessionId,
    required String newResult,
  }) async {
    final sessionRef = _firestore.collection('betting_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnap = await transaction.get(sessionRef);
      if (!sessionSnap.exists) throw Exception("Phiên cược không tồn tại");

      final query = await _firestore.collection('bets')
          .where('sessionId', isEqualTo: sessionId)
          .get();

      final bets = query.docs;
      final userIds = bets.map((d) => d.data()['userId'] as String).toSet().toList();

      final walletMap = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      for (final uid in userIds) {
        final walletRef = _firestore.collection('wallets').doc(uid);
        walletMap[uid] = await transaction.get(walletRef);
      }

      for (final betDoc in bets) {
        final betRef = betDoc.reference;
        final userId = betDoc.data()['userId'] as String;
        final choice = betDoc.data()['choice'] as String;
        final amount = (betDoc.data()['amount'] as num? ?? 0).toDouble();
        final odds = (betDoc.data()['oddsAtTime'] as num? ?? 1.0).toDouble();
        final oldStatus = betDoc.data()['status'] as String? ?? 'pending';

        final newStatus = (choice == newResult) ? 'won' : 'lost';
        if (oldStatus == newStatus) continue;

        double balanceChange = 0.0;
        if (oldStatus == 'won' && newStatus == 'lost') {
          balanceChange = -(amount * odds);
        } else if ((oldStatus == 'lost' || oldStatus == 'pending') && newStatus == 'won') {
          balanceChange = amount * odds;
        }

        transaction.update(betRef, {'status': newStatus});

        final walletSnap = walletMap[userId];
        if (walletSnap != null && walletSnap.exists) {
          final currentBalance = (walletSnap.data()?['balance'] as num? ?? 0).toDouble();
          transaction.update(walletSnap.reference, {'balance': currentBalance + balanceChange});

          final txRef = _firestore.collection('transactions').doc();
          transaction.set(txRef, {
            'id': txRef.id,
            'userId': userId,
            'amount': balanceChange,
            'type': balanceChange > 0 ? 'admin_win_adjustment' : 'admin_loss_adjustment',
            'description': 'Admin sửa kết quả phiên $sessionId sang $newResult',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      transaction.update(sessionRef, {
        'result': newResult,
        'isAdminOverride': true,
        'status': 'settled',
      });
    });
  }

  // Lấy N phiên cược đã kết toán gần nhất (để hiển thị lịch sử 10 phiên)
  Future<List<BettingSessionModel>> getRecentSessions({int limit = 10}) async {
    final snap = await _firestore
        .collection('betting_sessions')
        .where('status', isEqualTo: 'settled')
        .orderBy('sessionNumber', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((doc) => BettingSessionModel.fromFirestore(doc)).toList();
  }

  // Stream realtime N phiên gần nhất
  Stream<List<BettingSessionModel>> watchRecentSessions({int limit = 10}) {
    return _firestore
        .collection('betting_sessions')
        .where('status', isEqualTo: 'settled')
        .orderBy('sessionNumber', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => BettingSessionModel.fromFirestore(doc)).toList());
  }
}
