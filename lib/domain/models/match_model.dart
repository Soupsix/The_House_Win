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
    required double overUnderLine,
    @Default(false) bool isSimulated,
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
      overUnderLine: (data['overUnderLine'] as num?)?.toDouble() ?? 2.5,
      isSimulated: data['isSimulated'] as bool? ?? false,
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
      overUnderLine: (map['over_under_line'] as num).toDouble(),
      isSimulated: (map['is_simulated'] as int? ?? 0) == 1,
    );
  }
  // Factory tạo MatchModel từ FootballData.io API
  factory MatchModel.fromFootballDataApi(Map<String, dynamic> json) {
    final score = json['score'] ?? {};
    MatchStatus status;
    switch ((json['status'] ?? '').toString().toLowerCase()) {
      case 'finished':
      case 'complete':
        status = MatchStatus.finished;
        break;
      case 'live':
      case 'playing':
      case 'in_play':
        status = MatchStatus.inPlay;
        break;
      default:
        status = MatchStatus.scheduled;
    }

    return MatchModel(
      id: json['match_id'].toString(),
      homeTeam: json['home_team']['team_name'] ?? '',
      awayTeam: json['away_team']['team_name'] ?? '',
      utcDate: DateTime.parse(json['match_date']),
      status: status,
      scoreHome: score['home'] ?? 0,
      scoreAway: score['away'] ?? 0,
      result: null,

      // API free không có Over/Under
      oddsOver: 1.90,
      oddsUnder: 1.90,
      overUnderLine: 2.5,
      isSimulated: false,
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
      'overUnderLine': overUnderLine,
      'isSimulated': isSimulated,
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
      'over_under_line': overUnderLine,
      'is_simulated': isSimulated ? 1 : 0,
      'synced_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

}
