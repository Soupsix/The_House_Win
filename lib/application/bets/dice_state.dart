import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/enums/session_status.dart';
import 'bet_state.dart'; // Sử dụng lại BetDraftModel

part 'dice_state.freezed.dart';

// State đại diện cho Mini-game Tài Xỉu
@freezed
class DiceState with _$DiceState {
  const factory DiceState({
    // Phiên cược Tài Xỉu đang active
    BettingSessionModel? activeSession,
    // Countdown còn lại của phiên (60 → 0)
    @Default(60) int countdown,
    // Trạng thái phiên hiện tại
    @Default(SessionStatus.open) SessionStatus sessionStatus,
    
    // Đơn cược nháp đang nhập (chưa confirm)
    BetDraftModel? currentDraft,
    
    // Danh sách cược của user trong phiên hiện tại
    @Default([]) List<BetModel> currentSessionBets,
    
    // Lịch sử cược đã kết thúc
    @Default([]) List<BetModel> settledBets,
    
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? successMessage,
  }) = _DiceState;
}
