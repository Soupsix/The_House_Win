import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'simulation_state.dart';
import '../../domain/models/simulation_model.dart';
import '../../data/firebase/firestore_service.dart';

// Notifier quản lý mô phỏng Monte Carlo chống cờ bạc
class SimulationNotifier extends StateNotifier<SimulationState> {
  final FirestoreService _firestoreService;

  SimulationNotifier(this._firestoreService) : super(const SimulationState());

  // Cập nhật tham số mô phỏng
  void updateParams({
    int? numBets,
    double? betAmount,
    int? numPaths,
    double? oddsOver,
    double? oddsUnder,
  }) {
    state = state.copyWith(
      numBets: numBets ?? state.numBets,
      betAmount: betAmount ?? state.betAmount,
      numPaths: numPaths ?? state.numPaths,
      oddsOver: oddsOver ?? state.oddsOver,
      oddsUnder: oddsUnder ?? state.oddsUnder,
    );
  }

  // Chạy mô phỏng Monte Carlo trong Isolate để không block UI thread
  Future<void> runSimulation() async {
    state = state.copyWith(isRunning: true);
    
    // Đóng gói các tham số để truyền vào Isolate
    final params = {
      'numBets': state.numBets,
      'betAmount': state.betAmount,
      'numPaths': state.numPaths,
      'oddsOver': state.oddsOver,
      'oddsUnder': state.oddsUnder,
    };

    try {
      // Chạy tính toán nặng trong Isolate
      final paths = await compute(_computePaths, params);

      // Tính toán kết quả thống kê từ các đường chạy
      double totalFinalBalance = 0.0;
      int bustCount = 0;
      int profitCount = 0;
      const double initialBalance = 1000000.0;

      for (var path in paths) {
        final finalBalance = path.last;
        totalFinalBalance += finalBalance;

        // Nếu số dư cuối cùng nhỏ hơn tiền cược tối thiểu, coi như cháy túi (bust)
        if (finalBalance < state.betAmount) {
          bustCount++;
        } else if (finalBalance > initialBalance) {
          profitCount++;
        }
      }

      final avgFinalBalance = totalFinalBalance / state.numPaths;
      final houseEdge = calculateHouseEdge(state.oddsOver, state.oddsUnder);
      
      // EV tính trung bình cho odds của cửa Over
      final expectedValue = calculateEV(state.betAmount, state.oddsOver);

      final lastResult = SimulationResultModel(
        avgFinalBalance: avgFinalBalance,
        bustCount: bustCount,
        profitCount: profitCount,
        houseEdge: houseEdge,
        expectedValue: expectedValue,
        runAt: DateTime.now(),
      );

      state = state.copyWith(
        simulationPaths: paths,
        lastResult: lastResult,
        isRunning: false,
      );
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
      );
    }
  }

  // Hàm pure function chạy trong Isolate để giả lập các đường cược
  static List<List<double>> _computePaths(Map<String, dynamic> params) {
    final int numBets = params['numBets'] as int;
    final double betAmount = params['betAmount'] as double;
    final int numPaths = params['numPaths'] as int;
    final double oddsOver = params['oddsOver'] as double;
    final double oddsUnder = params['oddsUnder'] as double;

    final double sumImplied = (1 / oddsOver) + (1 / oddsUnder);
    // Xác suất thắng thực tế của cửa Over và Under sau khi trừ phế nhà cái
    final double probOver = (1 / oddsOver) / sumImplied;
    final double probUnder = (1 / oddsUnder) / sumImplied;

    final random = Random();
    final List<List<double>> paths = [];
    const double initialBalance = 1000000.0;

    for (int p = 0; p < numPaths; p++) {
      final List<double> path = [initialBalance];
      double currentBalance = initialBalance;

      for (int b = 0; b < numBets; b++) {
        if (currentBalance < betAmount) {
          // Bị cháy túi, dừng cược và ghi nhận số dư 0 cho các trận còn lại
          currentBalance = 0.0;
          path.add(currentBalance);
          continue;
        }

        // Người chơi chọn ngẫu nhiên Over hoặc Under (50% cơ hội mỗi bên)
        final bool betOnOver = random.nextBool();
        final double r = random.nextDouble();

        if (betOnOver) {
          if (r < probOver) {
            // Thắng cược Over
            currentBalance += betAmount * (oddsOver - 1);
          } else {
            // Thua cược Over
            currentBalance -= betAmount;
          }
        } else {
          if (r < probUnder) {
            // Thắng cược Under
            currentBalance += betAmount * (oddsUnder - 1);
          } else {
            // Thua cược Under
            currentBalance -= betAmount;
          }
        }

        path.add(currentBalance);
      }
      paths.add(path);
    }

    return paths;
  }

  // Tính tỷ lệ phế (House Edge) nhà cái giữ lại (%)
  double calculateHouseEdge(double oddsOver, double oddsUnder) {
    final sumImplied = (1 / oddsOver) + (1 / oddsUnder);
    if (sumImplied == 0) return 0.0;
    return ((sumImplied - 1) / sumImplied) * 100;
  }

  // Tính giá trị kỳ vọng (Expected Value - EV) của một đơn cược
  double calculateEV(double amount, double odds) {
    final sumImplied = (1 / state.oddsOver) + (1 / state.oddsUnder);
    if (sumImplied == 0) return 0.0;
    
    // Xác suất thắng thực tế
    final realProb = (1 / odds) / sumImplied;
    final profit = amount * (odds - 1);
    
    return (realProb * profit) - ((1 - realProb) * amount);
  }

  // Lưu kết quả mô phỏng vào Firestore simulations/{auto-id}
  Future<void> saveResult(String uid) async {
    final result = state.lastResult;
    if (result == null) return;

    try {
      await _firestoreService.saveSimulationResult({
        'userId': uid,
        ...result.toFirestore(),
      });
    } catch (e) {
      // Bỏ qua lỗi lưu Firestore
    }
  }
}
