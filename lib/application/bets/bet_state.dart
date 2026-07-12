import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/enums/bet_choice.dart';
import '../../domain/enums/session_status.dart';

part 'bet_state.freezed.dart';
part 'bet_state.g.dart';

// State đại diện cho các Đơn cược (cả Trận đấu bóng đá và phiên Tài Xỉu)
@freezed
class BetState with _$BetState {
  const factory BetState({
    // Đơn cược nháp đang nhập (chưa confirm)
    BetDraftModel? currentDraft,
    
    // Lịch sử cược đã kết thúc
    @Default([]) List<BetModel> settledBets,
    
    // Danh sách cược đang pending của bóng đá (giữ lại để tương thích)
    @Default([]) List<BetModel> pendingBets,
    
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? successMessage,
  }) = _BetState;
}

// Model cho cược nháp (Draft bet)
@freezed
class BetDraftModel with _$BetDraftModel {
  const factory BetDraftModel({
    String? matchId, // null nếu là cược Tài Xỉu
    String? sessionId, // null nếu là cược Bóng đá
    required BetChoice choice, // over hoặc under
    required double amount,
    required double oddsAtTime,
    required double potentialPayout, // amount * odds
  }) = _BetDraftModel;

  factory BetDraftModel.fromJson(Map<String, dynamic> json) =>
      _$BetDraftModelFromJson(json);
}
