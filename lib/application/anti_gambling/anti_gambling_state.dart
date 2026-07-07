import 'package:freezed_annotation/freezed_annotation.dart';

part 'anti_gambling_state.freezed.dart';

// State đại diện cho các tính năng cảnh báo và hạn chế cờ bạc (Anti-Gambling)
@freezed
class AntiGamblingState with _$AntiGamblingState {
  const factory AntiGamblingState({
    @Default(false) bool showLoanTrap, // hiện nút vay vốn giả (bẫy nợ để cảnh báo)
    @Default(false) bool showWarningOverlay, // hiện màn hình đỏ cảnh báo khẩn cấp
    @Default(0) int brokeCount, // số lần người chơi cháy túi
    @Default(0) int loanTrapClickCount, // số lần người chơi click bẫy vay vốn
    @Default(false) bool isLoading,
  }) = _AntiGamblingState;
}
