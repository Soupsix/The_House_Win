import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/models/notification_history_model.dart';

part 'notification_history_state.freezed.dart';

@freezed
class NotificationHistoryState with _$NotificationHistoryState {
  const factory NotificationHistoryState({
    @Default(true) bool isLoading,
    @Default([]) List<NotificationHistoryModel> notifications,
    String? errorMessage,
  }) = _NotificationHistoryState;
}
