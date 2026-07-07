import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/bet_choice.dart';
import '../enums/bet_status.dart';

part 'bet_model.freezed.dart';
part 'bet_model.g.dart';

// Model đại diện cho một Đơn cược
@freezed
class BetModel with _$BetModel {
  const factory BetModel({
    required String id,
    required String userId,
    required String matchId,
    required String homeTeam,
    required String awayTeam,
    required BetChoice choice,
    required double amount,
    required double oddsAtTime,
    @Default(0.0) double payout,
    required BetStatus status,
    required DateTime createdAt,
    DateTime? settledAt,
  }) = _BetModel;

  // Factory tạo BetModel từ JSON
  factory BetModel.fromJson(Map<String, dynamic> json) =>
      _$BetModelFromJson(json);

  // Factory tạo BetModel từ Firestore DocumentSnapshot
  factory BetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Bet data cannot be null");
    }
    return BetModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      matchId: data['matchId'] as String? ?? '',
      homeTeam: data['homeTeam'] as String? ?? '',
      awayTeam: data['awayTeam'] as String? ?? '',
      choice: BetChoice.values.firstWhere(
        (e) => e.name == data['choice'],
        orElse: () => BetChoice.over,
      ),
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      oddsAtTime: (data['oddsAtTime'] as num?)?.toDouble() ?? 0.0,
      payout: (data['payout'] as num?)?.toDouble() ?? 0.0,
      status: BetStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => BetStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      settledAt: (data['settledAt'] as Timestamp?)?.toDate(),
    );
  }

  // Factory tạo BetModel từ SQLite Map
  factory BetModel.fromSQLite(Map<String, dynamic> map) {
    return BetModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      matchId: map['match_id'] as String,
      homeTeam: map['home_team'] as String,
      awayTeam: map['away_team'] as String,
      choice: BetChoice.values.firstWhere(
        (e) => e.name == map['choice'],
        orElse: () => BetChoice.over,
      ),
      amount: (map['amount'] as num).toDouble(),
      oddsAtTime: (map['odds_at_time'] as num).toDouble(),
      payout: (map['payout'] as num).toDouble(),
      status: BetStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => BetStatus.pending,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      settledAt: map['settled_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['settled_at'] as int)
          : null,
    );
  }
}

// Extension cung cấp helper để lưu cược vào Firestore và SQLite
extension BetModelStorageExtension on BetModel {
  // Chuyển đổi BetModel thành Map lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'choice': choice.name,
      'amount': amount,
      'oddsAtTime': oddsAtTime,
      'payout': payout,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'settledAt': settledAt != null ? Timestamp.fromDate(settledAt!) : null,
    };
  }

  // Chuyển đổi BetModel thành Map lưu vào SQLite
  Map<String, dynamic> toSQLite() {
    return {
      'id': id,
      'user_id': userId,
      'match_id': matchId,
      'home_team': homeTeam,
      'away_team': awayTeam,
      'choice': choice.name,
      'amount': amount,
      'odds_at_time': oddsAtTime,
      'payout': payout,
      'status': status.name,
      'created_at': createdAt.millisecondsSinceEpoch,
      'settled_at': settledAt?.millisecondsSinceEpoch,
    };
  }
}
