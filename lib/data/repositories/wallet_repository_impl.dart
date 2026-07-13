import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/wallet_model.dart';
import '../../domain/models/transaction_model.dart';
import '../../domain/repositories/i_wallet_repository.dart';

class WalletRepositoryImpl implements IWalletRepository {
  final FirebaseFirestore _firestore;

  WalletRepositoryImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> createWallet(String userId, double initialBalance) async {
    final wallet = WalletModel(
      userId: userId,
      balance: initialBalance,
      lockedAmount: 0.0,
      isBroke: initialBalance < 1000,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('wallets').doc(userId).set(wallet.toFirestore());
  }

  @override
  Stream<WalletModel?> getWallet(String userId) {
    return _firestore
        .collection('wallets')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? WalletModel.fromFirestore(doc) : null);
  }

  @override
  Future<void> updateBalance(String userId, double amount, String type, {String? referenceId}) async {
    await _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await transaction.get(walletRef);

      if (!walletDoc.exists) throw Exception("Wallet not found");

      final currentBalance = (walletDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final currentIsBroke = walletDoc.data()?['isBroke'] as bool? ?? false;
      final newBalance = currentBalance + amount;

      transaction.update(walletRef, {
        'balance': newBalance,
        'isBroke': currentIsBroke || newBalance < 1000,
      });

      final transactionRef = _firestore.collection('transactions').doc();
      final transModel = TransactionModel(
        id: transactionRef.id,
        userId: userId,
        type: type,
        amount: amount,
        referenceId: referenceId,
        createdAt: DateTime.now(),
      );
      transaction.set(transactionRef, transModel.toFirestore());
    });
  }

  @override
  Future<void> lockFunds(String userId, double amount, String betId) async {
    await _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('wallets').doc(userId);
      final walletDoc = await transaction.get(walletRef);

      if (!walletDoc.exists) throw Exception("Wallet not found");

      final currentBalance = (walletDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final currentLocked = (walletDoc.data()?['lockedAmount'] as num?)?.toDouble() ?? 0.0;

      if (currentBalance < amount) throw Exception("Insufficient funds");

      transaction.update(walletRef, {
        'balance': currentBalance - amount,
        'lockedAmount': currentLocked + amount,
      });

      final transactionRef = _firestore.collection('transactions').doc();
      final transModel = TransactionModel(
        id: transactionRef.id,
        userId: userId,
        type: 'BET_LOCKED',
        amount: -amount,
        referenceId: betId,
        createdAt: DateTime.now(),
      );
      transaction.set(transactionRef, transModel.toFirestore());
    });
  }

  @override
  Future<void> payoutFunds(String userId, double amount, String betId) async {
    await updateBalance(userId, amount, 'BET_PAYOUT', referenceId: betId);
  }

  @override
  Future<void> resetWallet(String userId, double amount) async {
    await updateBalance(userId, amount, 'WALLET_RESET');
  }

  @override
  Stream<List<TransactionModel>> getTransactions(String userId) {
    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
    });
  }
}