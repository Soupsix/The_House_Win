import '../../domain/models/league_model.dart';
import '../../domain/models/match_model.dart';

class LeagueState {
  final List<LeagueModel> leagues;
  final List<MatchModel> leagueMatches;
  final LeagueModel? selectedLeague;
  final bool isLoadingLeagues;
  final bool isLoadingMatches;
  final String? errorLeagues;
  final String? errorMatches;

  const LeagueState({
    this.leagues = const [],
    this.leagueMatches = const [],
    this.selectedLeague,
    this.isLoadingLeagues = false,
    this.isLoadingMatches = false,
    this.errorLeagues,
    this.errorMatches,
  });

  LeagueState copyWith({
    List<LeagueModel>? leagues,
    List<MatchModel>? leagueMatches,
    LeagueModel? selectedLeague,
    bool? isLoadingLeagues,
    bool? isLoadingMatches,
    String? errorLeagues,
    String? errorMatches,
    bool clearLeagueError = false,
    bool clearMatchError = false,
  }) {
    return LeagueState(
      leagues: leagues ?? this.leagues,
      leagueMatches: leagueMatches ?? this.leagueMatches,
      selectedLeague: selectedLeague ?? this.selectedLeague,
      isLoadingLeagues: isLoadingLeagues ?? this.isLoadingLeagues,
      isLoadingMatches: isLoadingMatches ?? this.isLoadingMatches,
      errorLeagues: clearLeagueError ? null : (errorLeagues ?? this.errorLeagues),
      errorMatches: clearMatchError ? null : (errorMatches ?? this.errorMatches),
    );
  }
}
