import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'simulation_model.freezed.dart';
part 'simulation_model.g.dart';

// Model đại diện cho Kết quả mô phỏng Monte Carlo
@freezed
class SimulationResultModel with _$SimulationResultModel {
  const factory SimulationResultModel({
    required double avgFinalBalance,
    required int bustCount, // số đường cháy túi
    required int profitCount, // số đường còn lãi
    required double houseEdge,
    required double expectedValue,
    required DateTime runAt,
  }) = _SimulationResultModel;

  // Factory tạo SimulationResultModel từ JSON
  factory SimulationResultModel.fromJson(Map<String, dynamic> json) =>
      _$SimulationResultModelFromJson(json);

  // Factory tạo SimulationResultModel từ Firestore DocumentSnapshot
  factory SimulationResultModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Simulation result data cannot be null");
    }
    return SimulationResultModel(
      avgFinalBalance: (data['avgFinalBalance'] as num?)?.toDouble() ?? 0.0,
      bustCount: data['bustCount'] as int? ?? 0,
      profitCount: data['profitCount'] as int? ?? 0,
      houseEdge: (data['houseEdge'] as num?)?.toDouble() ?? 0.0,
      expectedValue: (data['expectedValue'] as num?)?.toDouble() ?? 0.0,
      runAt: (data['runAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// Extension cung cấp helper để lưu kết quả vào Firestore
extension SimulationResultModelFirestoreExtension on SimulationResultModel {
  // Chuyển đổi SimulationResultModel thành Map lưu trên Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'avgFinalBalance': avgFinalBalance,
      'bustCount': bustCount,
      'profitCount': profitCount,
      'houseEdge': houseEdge,
      'expectedValue': expectedValue,
      'runAt': Timestamp.fromDate(runAt),
    };
  }
}
