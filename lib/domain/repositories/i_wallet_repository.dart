import '../models/wallet_model.dart';
import '../models/transaction_model.dart';

abstract class IWalletRepository {
  Future<void> createWallet(String userId, double initialBalance);
  Stream<WalletModel?> getWallet(String userId);
  Future<void> updateBalance(String userId, double amount, String type, {String? referenceId});
  Future<void> lockFunds(String userId, double amount, String betId);
  Future<void> payoutFunds(String userId, double amount, String betId);
  Future<void> resetWallet(String userId, double amount);
  Stream<List<TransactionModel>> getTransactions(String userId);
}