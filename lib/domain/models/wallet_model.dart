import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'wallet_model.freezed.dart';
part 'wallet_model.g.dart';

// Model đại diện cho Ví ảo của người dùng
@freezed
class WalletModel with _$WalletModel {
  const factory WalletModel({
    required String userId,
    required double balance,
    required double lockedAmount,
    required bool isBroke,
    required DateTime createdAt,
  }) = _WalletModel;

  // Factory tạo WalletModel từ JSON
  factory WalletModel.fromJson(Map<String, dynamic> json) =>
      _$WalletModelFromJson(json);

  // Factory tạo WalletModel từ Firestore DocumentSnapshot
  factory WalletModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Wallet data cannot be null");
    }
    return WalletModel(
      userId: doc.id,
      balance: (data['balance'] as num?)?.toDouble() ?? 0.0,
      lockedAmount: (data['lockedAmount'] as num?)?.toDouble() ?? 0.0,
      isBroke: data['isBroke'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// Extension cung cấp helper để lưu ví vào Firestore
extension WalletModelFirestoreExtension on WalletModel {
  // Chuyển đổi WalletModel thành Map lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'balance': balance,
      'lockedAmount': lockedAmount,
      'isBroke': isBroke,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
