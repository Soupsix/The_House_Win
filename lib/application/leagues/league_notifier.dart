import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'league_state.dart';
import '../../data/remote/football_api/football_api_client.dart';
import '../../domain/models/league_model.dart';

class LeagueNotifier extends StateNotifier<LeagueState> {
  final FootballApiClient _apiClient;

  LeagueNotifier(this._apiClient) : super(const LeagueState());

  /// Lấy danh sách tất cả giải đấu
  Future<void> fetchLeagues() async {
    state = state.copyWith(isLoadingLeagues: true, clearLeagueError: true);
    try {
      final leagues = await _apiClient.fetchLeagues();
      state = state.copyWith(
        leagues: leagues,
        isLoadingLeagues: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingLeagues: false,
        errorLeagues: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Chọn một giải và lấy danh sách trận của giải đó (season mới nhất)
  Future<void> selectLeague(LeagueModel league) async {
    state = state.copyWith(
      selectedLeague: league,
      leagueMatches: [],
      isLoadingMatches: true,
      clearMatchError: true,
    );
    try {
      final matches = await _apiClient.fetchLeagueMatches(
        league.id,
        leagueName: league.name,
      );
      state = state.copyWith(
        leagueMatches: matches,
        isLoadingMatches: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMatches: false,
        errorMatches: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Refresh trận của giải đang xem
  Future<void> refreshLeagueMatches() async {
    final league = state.selectedLeague;
    if (league == null) return;
    await selectLeague(league);
  }
}
