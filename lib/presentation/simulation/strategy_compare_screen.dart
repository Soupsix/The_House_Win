import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class StrategyCompareScreen extends StatefulWidget {
  const StrategyCompareScreen({super.key});

  @override
  State<StrategyCompareScreen> createState() => _StrategyCompareScreenState();
}

class _StrategyCompareScreenState extends State<StrategyCompareScreen> {
  final int numBets = 100;
  final double initialBalance = 1000000;
  final double baseBet = 10000;
  
  List<double> flatPath = [];
  List<double> martingalePath = [];
  List<double> fibonacciPath = [];

  bool hasRun = false;

  void _runComparison() {
    // Sử dụng cùng 1 chuỗi kết quả (seed) cho cả 3 chiến lược
    final random = Random();
    final winSequence = List.generate(numBets, (_) => random.nextBool()); // Giả sử tỉ lệ thắng 50%
    
    // Tỉ lệ trả thưởng giả định (odds = 1.95 để có house edge)
    const odds = 1.95; 
    
    setState(() {
      flatPath = _simulateFlat(winSequence, odds);
      martingalePath = _simulateMartingale(winSequence, odds);
      fibonacciPath = _simulateFibonacci(winSequence, odds);
      hasRun = true;
    });
  }

  List<double> _simulateFlat(List<bool> winSeq, double odds) {
    double balance = initialBalance;
    List<double> path = [balance];
    
    for (bool isWin in winSeq) {
      if (balance < baseBet) {
        path.add(balance); // Cháy túi
        continue;
      }
      if (isWin) {
        balance += baseBet * (odds - 1);
      } else {
        balance -= baseBet;
      }
      path.add(balance);
    }
    return path;
  }

  List<double> _simulateMartingale(List<bool> winSeq, double odds) {
    double balance = initialBalance;
    List<double> path = [balance];
    double currentBet = baseBet;
    
    for (bool isWin in winSeq) {
      if (balance < currentBet) {
        path.add(balance); // Cháy túi
        continue;
      }
      if (isWin) {
        balance += currentBet * (odds - 1);
        currentBet = baseBet; // Reset cược sau khi thắng
      } else {
        balance -= currentBet;
        currentBet *= 2; // Gấp đôi cược sau khi thua
      }
      path.add(balance);
    }
    return path;
  }

  List<double> _simulateFibonacci(List<bool> winSeq, double odds) {
    double balance = initialBalance;
    List<double> path = [balance];
    
    List<int> fibSeq = [1, 1];
    int fibIndex = 0;
    
    for (bool isWin in winSeq) {
      // Đảm bảo tạo đủ dãy fib
      while (fibSeq.length <= fibIndex + 2) {
        fibSeq.add(fibSeq[fibSeq.length - 1] + fibSeq[fibSeq.length - 2]);
      }
      
      double currentBet = baseBet * fibSeq[fibIndex];
      if (balance < currentBet) {
        path.add(balance); // Cháy túi
        continue;
      }
      
      if (isWin) {
        balance += currentBet * (odds - 1);
        fibIndex = max(0, fibIndex - 2); // Thắng thì lùi 2 bước
      } else {
        balance -= currentBet;
        fibIndex++; // Thua thì tiến 1 bước
      }
      path.add(balance);
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'SO SÁNH CHIẾN LƯỢC CƯỢC',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFFF5F5F5),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Cùng một chuỗi 100 trận đấu, các chiến lược quản lý vốn (như gấp thếp Martingale) thường dẫn đến cháy túi nhanh hơn bạn tưởng.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          ElevatedButton(
            onPressed: _runComparison,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'CHẠY SO SÁNH 100 TRẬN',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          if (hasRun) ...[
            Container(
              height: 350,
              padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2030),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E3050)),
              ),
              child: _buildChart(),
            ),
            const SizedBox(height: 24),
            _buildLegend(),
          ] else
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: const Color(0xFF1E2030),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E3050)),
              ),
              child: const Center(
                child: Text(
                  'Nhấn nút để chạy mô phỏng.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3050)),
      ),
      child: Column(
        children: [
          _legendItem(Colors.blue, 'Flat Betting', 'Cược đều 10k mỗi ván', flatPath.last),
          const Divider(color: Color(0xFF2E3050), height: 24),
          _legendItem(Colors.red, 'Martingale', 'Thua x2 tiền cược', martingalePath.last),
          const Divider(color: Color(0xFF2E3050), height: 24),
          _legendItem(Colors.orange, 'Fibonacci', 'Tăng theo chuỗi Fibonacci', fibonacciPath.last),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String title, String subtitle, double finalBalance) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                  fontSize: 14,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Số dư: ${(finalBalance / 1000).toStringAsFixed(0)}k',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            color: finalBalance < baseBet ? Colors.red : const Color(0xFF00D4AA),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    double maxVal = max(
      flatPath.reduce(max),
      max(martingalePath.reduce(max), fibonacciPath.reduce(max)),
    );
    maxVal = maxVal * 1.1; // padding top

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: const Color(0xFF2E3050).withValues(alpha: 0.5),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: const Color(0xFF2E3050).withValues(alpha: 0.5),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: maxVal / 5,
              getTitlesWidget: (value, meta) {
                if (value == 0) return const SizedBox.shrink();
                String text = value >= 1000000
                    ? '${(value / 1000000).toStringAsFixed(1)}M'
                    : '${(value / 1000).toStringAsFixed(0)}k';
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    text,
                    style: const TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: numBets.toDouble(),
        minY: 0,
        maxY: maxVal,
        lineBarsData: [
          _createLine(flatPath, Colors.blue),
          _createLine(martingalePath, Colors.red),
          _createLine(fibonacciPath, Colors.orange),
        ],
      ),
    );
  }

  LineChartBarData _createLine(List<double> path, Color color) {
    List<FlSpot> spots = [];
    for (int i = 0; i < path.length; i++) {
      spots.add(FlSpot(i.toDouble(), path[i]));
    }
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
    );
  }
}
