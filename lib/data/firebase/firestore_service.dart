import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toFirestore());
    await createWalletDocument(user.uid);
  }

  Future<void> updateUserProfile(String uid, String displayName, String phoneNumber) async {
    await _firestore.collection('users').doc(uid).update({
      'displayName': displayName,
      'phoneNumber': phoneNumber,
    });
  }

  Future<void> createWalletDocument(String uid) async {
    await _firestore.collection('wallets').doc(uid).set({
      'balance': 1000000,
      'lockedAmount': 0,
      'isBroke': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUserDocument(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<bool> isAdmin(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data();
    if (data == null) return false;
    return data['isAdmin'] as bool? ?? false;
  }

  // --- Wallet Operations ---

  // Lấy Stream realtime của Ví ảo
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchWalletDocument(String uid) {
    return _firestore.collection('wallets').doc(uid).snapshots();
  }

  // Lấy dữ liệu ví hiện tại
  Future<DocumentSnapshot<Map<String, dynamic>>> getWalletDocument(String uid) async {
    return await _firestore.collection('wallets').doc(uid).get();
  }

  // Thực hiện giao dịch (Transaction) Firestore để đặt cược (Deduct Bet)
  Future<void> runDeductBetTransaction({
    required String uid,
    required double amount,
    required String betId,
  }) async {
    final walletRef = _firestore.collection('wallets').doc(uid);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception("Ví ảo không tồn tại");
      }

      final data = walletDoc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      final lockedAmount = (data['lockedAmount'] as num?)?.toDouble() ?? 0.0;
      final availableBalance = balance - lockedAmount;

      if (availableBalance < amount) {
        throw Exception("Số dư khả dụng không đủ để thực hiện đặt cược");
      }

      transaction.update(walletRef, {
        'balance': balance - amount,
        'lockedAmount': lockedAmount + amount,
      });

      transaction.set(transactionRef, {
        'userId': uid,
        'type': 'BET_LOCKED',
        'amount': amount,
        'referenceId': betId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Thực hiện giải quyết cược (Settle Bet) trong Firestore
  Future<void> runSettleBetTransaction({
    required String uid,
    required double amount,
    required double payout,
    required String betId,
    required bool isWin,
  }) async {
    final walletRef = _firestore.collection('wallets').doc(uid);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception("Ví ảo không tồn tại");
      }

      final data = walletDoc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;
      final lockedAmount = (data['lockedAmount'] as num?)?.toDouble() ?? 0.0;

      final nextLockedAmount = (lockedAmount - amount < 0) ? 0.0 : lockedAmount - amount;
      final nextBalance = isWin ? (balance + payout) : balance;

      transaction.update(walletRef, {
        'lockedAmount': nextLockedAmount,
        'balance': nextBalance,
      });

      transaction.set(transactionRef, {
        'userId': uid,
        'type': isWin ? 'BET_WIN' : 'BET_LOSE',
        'amount': isWin ? payout : amount,
        'referenceId': betId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Cập nhật trạng thái cháy túi (isBroke) trong Firestore
  Future<void> updateIsBrokeStatus(String uid, bool isBroke) async {
    await _firestore.collection('wallets').doc(uid).update({
      'isBroke': isBroke,
    });
  }

  // Tăng số lần cháy túi (brokeCount) trong Firestore users/{uid}
  Future<void> incrementBrokeCount(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'brokeCount': FieldValue.increment(1),
    });
  }

  // Tăng số lần click bẫy vay vốn (loanTrapClickCount) trong Firestore users/{uid}
  Future<void> incrementLoanTrapClickCount(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'loanTrapClickCount': FieldValue.increment(1),
    });
  }

  // Admin rút tiền từ ví người chơi
  Future<void> runAdminWithdrawTransaction({
    required String uid,
    required double amount,
  }) async {
    final walletRef = _firestore.collection('wallets').doc(uid);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      final walletDoc = await transaction.get(walletRef);
      if (!walletDoc.exists) {
        throw Exception("Ví ảo không tồn tại");
      }

      final data = walletDoc.data()!;
      final balance = (data['balance'] as num?)?.toDouble() ?? 0.0;

      final nextBalance = (balance - amount < 0) ? 0.0 : balance - amount;

      transaction.update(walletRef, {
        'balance': nextBalance,
      });

      transaction.set(transactionRef, {
        'userId': uid,
        'type': 'ADMIN_WITHDRAW',
        'amount': amount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Reset ví về mặc định và xóa lịch sử giao dịch ví của người chơi đó
  Future<void> runResetWalletTransaction(String uid) async {
    final walletRef = _firestore.collection('wallets').doc(uid);
    final transactionRef = _firestore.collection('transactions').doc();

    await _firestore.runTransaction((transaction) async {
      transaction.update(walletRef, {
        'balance': 1000000.0,
        'lockedAmount': 0.0,
        'isBroke': false,
      });

      transaction.set(transactionRef, {
        'userId': uid,
        'type': 'WALLET_RESET',
        'amount': 1000000.0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    // Xóa lịch sử giao dịch
    final transSnap = await _firestore.collection('transactions')
        .where('userId', isEqualTo: uid)
        .get();
    
    final batch = _firestore.batch();
    for (var doc in transSnap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // Đọc 20 giao dịch ví gần nhất từ collection transactions
  Future<QuerySnapshot<Map<String, dynamic>>> getTransactionsLimit20(String uid) async {
    return await _firestore.collection('transactions')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .get();
  }

  // --- Matches Operations ---

  // Giải quyết trận đấu (Settle Match)
  Future<void> settleMatchInFirestore(String matchId, String resultName) async {
    await _firestore.collection('matches').doc(matchId).update({
      'result': resultName,
      'status': 'finished',
    });
  }

  // Lưu trận đấu (thật hoặc giả lập) vào Firestore
  Future<void> saveMatchInFirestore(String matchId, Map<String, dynamic> data) async {
    await _firestore.collection('matches').doc(matchId).set(data);
  }

  // --- Bets Operations ---

  // Lưu cược vào Firestore
  Future<void> saveBetInFirestore(String betId, Map<String, dynamic> data) async {
    await _firestore.collection('bets').doc(betId).set(data);
  }

  // Lọc danh sách cược pending của người chơi
  Future<QuerySnapshot<Map<String, dynamic>>> getPendingBets(String uid) async {
    return await _firestore.collection('bets')
        .where('userId', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .get();
  }

  // Lọc danh sách cược đã giải quyết (settled) của người chơi
  Future<QuerySnapshot<Map<String, dynamic>>> getSettledBetsLimit50(String uid) async {
    return await _firestore.collection('bets')
        .where('userId', isEqualTo: uid)
        .where('status', isNotEqualTo: 'pending')
        .orderBy('status') // Firestore requires this if using order by on createdAt with inequality filter, or we can just filter in memory or order by createdAt if index exists. Wait, standard firestore query: where userId = uid and status != pending order by status, createdAt desc. Or we order by createdAt desc in memory. Let's do simple query.
        .limit(50)
        .get();
  }

  // Lấy các đơn cược pending của một trận đấu
  Future<QuerySnapshot<Map<String, dynamic>>> getPendingBetsForMatch(String matchId) async {
    return await _firestore.collection('bets')
        .where('matchId', isEqualTo: matchId)
        .where('status', isEqualTo: 'pending')
        .get();
  }

  // Cập nhật trạng thái cược
  Future<void> updateBetStatus(String betId, String statusName, double payout, DateTime settledAt) async {
    await _firestore.collection('bets').doc(betId).update({
      'status': statusName,
      'payout': payout,
      'settledAt': Timestamp.fromDate(settledAt),
    });
  }

  // Đọc thông tin trận đấu
  Future<DocumentSnapshot<Map<String, dynamic>>> getMatchDocument(String matchId) async {
    return await _firestore.collection('matches').doc(matchId).get();
  }

  // Đọc thông tin cược
  Future<DocumentSnapshot<Map<String, dynamic>>> getBetDocument(String betId) async {
    return await _firestore.collection('bets').doc(betId).get();
  }

  // --- Admin Logs ---

  // Ghi log hành động admin vào Firestore collection admin_logs
  Future<void> writeAdminLog(String action, Map<String, dynamic> details) async {
    await _firestore.collection('admin_logs').add({
      'action': action,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // --- Simulations ---

  // Lưu kết quả mô phỏng Monte Carlo vào Firestore simulations/{auto-id}
  Future<void> saveSimulationResult(Map<String, dynamic> data) async {
    await _firestore.collection('simulations').add(data);
  }
}
