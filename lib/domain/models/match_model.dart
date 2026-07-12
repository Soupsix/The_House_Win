import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/match_status.dart';

part 'match_model.freezed.dart';
part 'match_model.g.dart';

// Model đại diện cho Trận đấu bóng đá
@freezed
class MatchModel with _$MatchModel {
  const factory MatchModel({
    required String id,
    required String homeTeam,
    required String awayTeam,
    required DateTime utcDate,
    required MatchStatus status,
    @Default(0) int scoreHome,
    @Default(0) int scoreAway,
    MatchResult? result,
    required double oddsOver,
    required double oddsUnder,
    @Default(3.2) double oddsDraw,
    required double overUnderLine,
    @Default(false) bool isSimulated,
    @Default('') String leagueName,
    @Default('') String homeTeamLogo,
    @Default('') String awayTeamLogo,
  }) = _MatchModel;

  // Factory tạo MatchModel từ JSON
  factory MatchModel.fromJson(Map<String, dynamic> json) =>
      _$MatchModelFromJson(json);

  // Factory tạo MatchModel từ Firestore DocumentSnapshot
  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Match data cannot be null");
    }
    return MatchModel(
      id: doc.id,
      homeTeam: data['homeTeam'] as String? ?? '',
      awayTeam: data['awayTeam'] as String? ?? '',
      utcDate: (data['utcDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      scoreHome: data['scoreHome'] as int? ?? 0,
      scoreAway: data['scoreAway'] as int? ?? 0,
      result: data['result'] != null
          ? MatchResult.values.firstWhere((e) => e.name == data['result'])
          : null,
      oddsOver: (data['oddsOver'] as num?)?.toDouble() ?? 1.85,
      oddsUnder: (data['oddsUnder'] as num?)?.toDouble() ?? 1.95,
      oddsDraw: (data['oddsDraw'] as num?)?.toDouble() ?? 3.2,
      overUnderLine: (data['overUnderLine'] as num?)?.toDouble() ?? 2.5,
      isSimulated: data['isSimulated'] as bool? ?? false,
      leagueName: data['leagueName'] as String? ?? '',
      homeTeamLogo: data['homeTeamLogo'] as String? ?? '',
      awayTeamLogo: data['awayTeamLogo'] as String? ?? '',
    );
  }

  // Factory tạo MatchModel từ SQLite Map
  factory MatchModel.fromSQLite(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'] as String,
      homeTeam: map['home_team'] as String,
      awayTeam: map['away_team'] as String,
      utcDate: DateTime.fromMillisecondsSinceEpoch(map['utc_date'] as int),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      scoreHome: map['score_home'] as int? ?? 0,
      scoreAway: map['score_away'] as int? ?? 0,
      result: map['result'] != null
          ? MatchResult.values.firstWhere((e) => e.name == map['result'])
          : null,
      oddsOver: (map['odds_over'] as num).toDouble(),
      oddsUnder: (map['odds_under'] as num).toDouble(),
      oddsDraw: (map['odds_draw'] as num?)?.toDouble() ?? 3.2,
      overUnderLine: (map['over_under_line'] as num).toDouble(),
      isSimulated: (map['is_simulated'] as int? ?? 0) == 1,
      leagueName: map['league_name'] as String? ?? '',
      homeTeamLogo: map['home_team_logo'] as String? ?? '',
      awayTeamLogo: map['away_team_logo'] as String? ?? '',
    );
  }
}

// Extension cung cấp helper để lưu trận đấu vào Firestore và SQLite
extension MatchModelStorageExtension on MatchModel {
  // Chuyển đổi MatchModel thành Map lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'utcDate': Timestamp.fromDate(utcDate),
      'status': status.name,
      'scoreHome': scoreHome,
      'scoreAway': scoreAway,
      'result': result?.name,
      'oddsOver': oddsOver,
      'oddsUnder': oddsUnder,
      'oddsDraw': oddsDraw,
      'overUnderLine': overUnderLine,
      'isSimulated': isSimulated,
      'leagueName': leagueName,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
    };
  }

  // Chuyển đổi MatchModel thành Map lưu vào SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'utc_date': utcDate.millisecondsSinceEpoch,
      'status': status.name,
      'score_home': scoreHome,
      'score_away': scoreAway,
      'result': result?.name,
      'odds_over': oddsOver,
      'odds_under': oddsUnder,
      'odds_draw': oddsDraw,
      'over_under_line': overUnderLine,
      'is_simulated': isSimulated ? 1 : 0,
      'league_name': leagueName,
      'home_team_logo': homeTeamLogo,
      'away_team_logo': awayTeamLogo,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    };
  }
}
