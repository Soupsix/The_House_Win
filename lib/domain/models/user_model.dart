import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String uid,
    required String email,
    required String displayName,
    required bool isAdmin,
    required DateTime createdAt,
    required String phoneNumber,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("User data cannot be null");
    }

    // Safe casting for isAdmin
    final isAdminRaw = data['isAdmin'];
    bool isAdmin = false;
    if (isAdminRaw is bool) {
      isAdmin = isAdminRaw;
    } else if (isAdminRaw is String) {
      isAdmin = isAdminRaw.toLowerCase() == 'true';
    } else if (isAdminRaw is num) {
      isAdmin = isAdminRaw == 1;
    }

    // Safe casting for createdAt
    final createdAtRaw = data['createdAt'];
    DateTime createdAt = DateTime.now();
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else if (createdAtRaw is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtRaw);
    }

    return UserModel(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      displayName: data['displayName']?.toString() ?? '',
      isAdmin: isAdmin,
      createdAt: createdAt,
      phoneNumber: data['phoneNumber']?.toString() ?? '',
    );
  }
}

extension UserModelFirestoreExtension on UserModel {
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'isAdmin': isAdmin,
      'createdAt': Timestamp.fromDate(createdAt),
      'phoneNumber': phoneNumber,
    };
  }
}
