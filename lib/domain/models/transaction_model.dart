import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/game_type.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

// Model đại diện cho Lịch sử giao dịch ví ảo
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String userId,
    required String type, // Ví dụ: "BET_LOCKED", "BET_WIN", "BET_LOSE", "ADMIN_WITHDRAW", "WALLET_RESET"
    required double amount,
    String? referenceId, // id của đối tượng liên quan (ví dụ: betId)
    GameType? gameType,
    required DateTime createdAt,
  }) = _TransactionModel;

  // Factory tạo TransactionModel từ JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  // Factory tạo TransactionModel từ Firestore DocumentSnapshot
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Transaction data cannot be null");
    }
    
    // Parse GameType safely
    GameType? gameType;
    if (data['gameType'] != null) {
      final gtStr = data['gameType'] as String;
      gameType = GameType.values.firstWhere(
        (e) => e.name == gtStr,
        orElse: () => GameType.diceOverUnder, // fallback
      );
    }

    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      referenceId: data['referenceId'] as String?,
      gameType: gameType,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// Extension cung cấp helper để lưu giao dịch vào Firestore
extension TransactionModelFirestoreExtension on TransactionModel {
  // Chuyển đổi TransactionModel thành Map lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'amount': amount,
      'referenceId': referenceId,
      if (gameType != null) 'gameType': gameType!.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
