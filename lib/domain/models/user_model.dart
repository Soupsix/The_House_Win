import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_settings_model.dart';

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
    String? fcmToken,
    DateTime? fcmTokenUpdatedAt,
    @Default(NotificationSettingsModel()) NotificationSettingsModel notificationSettings,
    DateTime? lastOpen,
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

    // Safe casting for fcmTokenUpdatedAt
    final tokenUpdatedAtRaw = data['fcmTokenUpdatedAt'];
    DateTime? fcmTokenUpdatedAt;
    if (tokenUpdatedAtRaw is Timestamp) {
      fcmTokenUpdatedAt = tokenUpdatedAtRaw.toDate();
    } else if (tokenUpdatedAtRaw is String) {
      fcmTokenUpdatedAt = DateTime.tryParse(tokenUpdatedAtRaw);
    } else if (tokenUpdatedAtRaw is int) {
      fcmTokenUpdatedAt = DateTime.fromMillisecondsSinceEpoch(tokenUpdatedAtRaw);
    }

    // Safe casting for lastOpen
    final lastOpenRaw = data['lastOpen'];
    DateTime? lastOpen;
    if (lastOpenRaw is Timestamp) {
      lastOpen = lastOpenRaw.toDate();
    } else if (lastOpenRaw is String) {
      lastOpen = DateTime.tryParse(lastOpenRaw);
    } else if (lastOpenRaw is int) {
      lastOpen = DateTime.fromMillisecondsSinceEpoch(lastOpenRaw);
    }

    final settingsRaw = data['notificationSettings'] as Map<String, dynamic>?;
    final notificationSettings = settingsRaw != null 
        ? NotificationSettingsModel.fromJson(settingsRaw) 
        : const NotificationSettingsModel();

    return UserModel(
      uid: doc.id,
      email: data['email']?.toString() ?? '',
      displayName: data['displayName']?.toString() ?? '',
      isAdmin: isAdmin,
      createdAt: createdAt,
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      fcmToken: data['fcmToken']?.toString(),
      fcmTokenUpdatedAt: fcmTokenUpdatedAt,
      notificationSettings: notificationSettings,
      lastOpen: lastOpen,
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
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (fcmTokenUpdatedAt != null) 'fcmTokenUpdatedAt': Timestamp.fromDate(fcmTokenUpdatedAt!),
      'notificationSettings': notificationSettings.toJson(),
      if (lastOpen != null) 'lastOpen': Timestamp.fromDate(lastOpen!),
    };
  }
}
