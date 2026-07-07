import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/enums/bet_choice.dart';

part 'bet_state.freezed.dart';


// State đại diện cho các Đơn cược
@freezed
class BetState with _$BetState {
  const factory BetState({
    @Default([]) List<BetModel> pendingBets,
    @Default([]) List<BetModel> settledBets,
    BetDraftModel? currentDraft, // bet đang nhập chưa confirm
    @Default(false) bool isSubmitting,
    @Default(false) bool isLoading,
    String? errorMessage,
    String? successMessage,
  }) = _BetState;
}

// Model cho cược nháp (Draft bet) — chưa confirm, chỉ tồn tại trong bộ nhớ RAM
@freezed
class BetDraftModel with _$BetDraftModel {
  const factory BetDraftModel({
    required String matchId,
    required BetChoice choice, // over hoặc under
    required double amount,
    required double oddsAtTime,
    required double potentialPayout, // amount * odds
  }) = _BetDraftModel;
}
