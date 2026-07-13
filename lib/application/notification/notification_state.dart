import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_state.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default(false) bool isLoading,
    @Default(false) bool isPermissionGranted,
    String? fcmToken,
    String? errorMessage,
  }) = _NotificationState;
}
