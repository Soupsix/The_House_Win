import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/match_model.dart';

part 'match_state.freezed.dart';

// State đại diện cho các Trận đấu bóng đá
@freezed
class MatchState with _$MatchState {
  const factory MatchState({
    @Default([]) List<MatchModel> scheduledMatches,
    @Default([]) List<MatchModel> liveMatches,
    @Default([]) List<MatchModel> finishedMatches,
    @Default(false) bool isRefreshing,
    MatchModel? selectedMatch,
    DateTime? lastSyncAt,
    String? errorMessage,
  }) = _MatchState;
}
