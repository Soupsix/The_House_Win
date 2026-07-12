import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../enums/session_status.dart';

part 'betting_session_model.freezed.dart';
part 'betting_session_model.g.dart';

// Model đại diện cho một phiên cược Tài Xỉu (60 giây)
@freezed
class BettingSessionModel with _$BettingSessionModel {
  const factory BettingSessionModel({
    required String sessionId,
    required int sessionNumber,
    required SessionStatus status,
    required DateTime startedAt,
    DateTime? lockedAt,
    DateTime? settledAt,
    String? result, // null, 'over', 'under'
    @Default(false) bool isAdminOverride,
    @Default(0.0) double totalOverBets,
    @Default(0.0) double totalUnderBets,
    @Default(1.85) double oddsOver,
    @Default(1.95) double oddsUnder,
    @Default(2.5) double overUnderLine,
  }) = _BettingSessionModel;

  // Factory tạo BettingSessionModel từ JSON
  factory BettingSessionModel.fromJson(Map<String, dynamic> json) =>
      _$BettingSessionModelFromJson(json);

  // Factory constructor từ Firestore DocumentSnapshot
  factory BettingSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Session data cannot be null");
    }
    
    final statusStr = data['status'] as String? ?? 'open';
    final status = SessionStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => SessionStatus.open,
    );

    return BettingSessionModel(
      sessionId: doc.id,
      sessionNumber: (data['sessionNumber'] as num?)?.toInt() ?? 0,
      status: status,
      startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lockedAt: (data['lockedAt'] as Timestamp?)?.toDate(),
      settledAt: (data['settledAt'] as Timestamp?)?.toDate(),
      result: data['result'] as String?,
      isAdminOverride: data['isAdminOverride'] as bool? ?? false,
      totalOverBets: (data['totalOverBets'] as num?)?.toDouble() ?? 0.0,
      totalUnderBets: (data['totalUnderBets'] as num?)?.toDouble() ?? 0.0,
      oddsOver: (data['oddsOver'] as num?)?.toDouble() ?? 1.85,
      oddsUnder: (data['oddsUnder'] as num?)?.toDouble() ?? 1.95,
      overUnderLine: (data['overUnderLine'] as num?)?.toDouble() ?? 2.5,
    );
  }
}

// Extension to convert to Firestore map
extension BettingSessionModelStorageExtension on BettingSessionModel {
  Map<String, dynamic> toFirestore() {
    return {
      'sessionNumber': sessionNumber,
      'status': status.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'lockedAt': lockedAt != null ? Timestamp.fromDate(lockedAt!) : null,
      'settledAt': settledAt != null ? Timestamp.fromDate(settledAt!) : null,
      'result': result,
      'isAdminOverride': isAdminOverride,
      'totalOverBets': totalOverBets,
      'totalUnderBets': totalUnderBets,
      'oddsOver': oddsOver,
      'oddsUnder': oddsUnder,
      'overUnderLine': overUnderLine,
    };
  }
}
