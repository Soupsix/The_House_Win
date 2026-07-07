import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/simulation_model.dart';

part 'simulation_state.freezed.dart';

// State đại diện cho Mô phỏng Monte Carlo chống cờ bạc
@freezed
class SimulationState with _$SimulationState {
  const factory SimulationState({
    @Default(100) int numBets, // số trận đặt cược trong một chuỗi mô phỏng
    @Default(50000) double betAmount, // số tiền cược cố định mỗi trận
    @Default(5) int numPaths, // số đường chạy mô phỏng song song (tối đa 5 đường để vẽ biểu đồ)
    @Default(1.85) double oddsOver, // tỷ lệ ăn cược cửa Tài
    @Default(1.95) double oddsUnder, // tỷ lệ ăn cược cửa Xỉu
    @Default([]) List<List<double>> simulationPaths, // lịch sử số dư cho từng đường chạy
    @Default(false) bool isRunning, // trạng thái đang tính toán mô phỏng
    SimulationResultModel? lastResult, // kết quả mô phỏng cuối cùng thu được
  }) = _SimulationState;
}

// Extension cung cấp các getter tính toán các giá trị lý thuyết của nhà cái
extension SimulationStateX on SimulationState {
  // Tính tỷ lệ phần trăm nhà cái giữ lại (House Edge)
  double get calculatedHouseEdge {
    final sumImplied = (1 / oddsOver) + (1 / oddsUnder);
    if (sumImplied == 0) return 0.0;
    return ((sumImplied - 1) / sumImplied) * 100;
  }

  // Tính giá trị kỳ vọng (Expected Value - EV) cho mỗi đồng tiền đặt cược (luôn âm)
  double get calculatedEV {
    final sumImplied = (1 / oddsOver) + (1 / oddsUnder);
    if (sumImplied == 0) return 0.0;
    return (1 / sumImplied) - 1;
  }
}
