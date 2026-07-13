import 'dart:math';

class SpinSegmentModel {
  final String id;
  final double multiplier;
  final double probability;
  final String label;

  SpinSegmentModel(this.id, this.multiplier, this.probability, this.label);
}

void main() {
  final segments = [
    SpinSegmentModel('seg_x0', 0.0, 0.349, 'x0'),
    SpinSegmentModel('seg_x0_5', 0.5, 0.20, 'x0.5'),
    SpinSegmentModel('seg_x1', 1.0, 0.18, 'x1'),
    SpinSegmentModel('seg_x1_5', 1.5, 0.12, 'x1.5'),
    SpinSegmentModel('seg_x2', 2.0, 0.08, 'x2'),
    SpinSegmentModel('seg_x3', 3.0, 0.04, 'x3'),
    SpinSegmentModel('seg_x5', 5.0, 0.02, 'x5'),
    SpinSegmentModel('seg_x10', 10.0, 0.011, 'x10'),
  ];

  final Map<String, int> results = {};
  for (var s in segments) {
    results[s.id] = 0;
  }

  const int NUM_TESTS = 100000;
  final random = Random.secure();
  
  double totalBet = NUM_TESTS * 1.0;
  double totalPayout = 0.0;

  for (int i = 0; i < NUM_TESTS; i++) {
    final double randVal = random.nextDouble();
    double cumulative = 0.0;
    SpinSegmentModel? selected;
    
    for (final segment in segments) {
      cumulative += segment.probability;
      if (randVal <= cumulative) {
        selected = segment;
        break;
      }
    }
    selected ??= segments.last;

    results[selected.id] = results[selected.id]! + 1;
    totalPayout += selected.multiplier * 1.0;
  }

  print('=== KẾT QUẢ TEST RANDOM.SECURE() SAU $NUM_TESTS LẦN QUAY ===');
  for (var s in segments) {
    final count = results[s.id]!;
    final actualProb = count / NUM_TESTS;
    final diff = (actualProb - s.probability).abs();
    print('${s.label.padRight(5)} | Expected: ${(s.probability * 100).toStringAsFixed(1)}% | Actual: ${(actualProb * 100).toStringAsFixed(2)}% | Diff: ${(diff * 100).toStringAsFixed(3)}%');
  }
  
  print('========================================================');
  print('Tổng Bet:    $totalBet');
  print('Tổng Payout: $totalPayout');
  print('EV Thực Tế:  ${(totalPayout / totalBet).toStringAsFixed(4)} (Mục tiêu: 0.95)');
}
