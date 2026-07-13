import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/simulation/simulation_provider.dart';

class MonteCarloChart extends ConsumerWidget {
  const MonteCarloChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final paths = state.simulationPaths;

    if (paths.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: const Color(0xFF1E2030),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E3050)),
        ),
        child: const Center(
          child: Text(
            'Chưa có dữ liệu mô phỏng.\nHãy nhấn "CHẠY MÔ PHỎNG".',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Danh sách màu cho các đường chạy
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.teal,
    ];

    double maxVal = 0;
    for (var path in paths) {
      for (var val in path) {
        if (val > maxVal) maxVal = val;
      }
    }
    // Limit max value slightly above the peak for padding
    maxVal = maxVal * 1.1;

    return Container(
      height: 350,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3050)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxVal / 5,
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
                interval: (state.numBets / 5).clamp(1.0, state.numBets.toDouble()),
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
                  // Rút gọn text (ví dụ 1000000 -> 1M)
                  String text = '';
                  if (value >= 1000000) {
                    text = '${(value / 1000000).toStringAsFixed(1)}M';
                  } else if (value >= 1000) {
                    text = '${(value / 1000).toStringAsFixed(0)}k';
                  } else {
                    text = value.toStringAsFixed(0);
                  }
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
          maxX: state.numBets.toDouble(),
          minY: 0,
          maxY: maxVal,
          lineBarsData: paths.asMap().entries.map((entry) {
            int index = entry.key;
            List<double> path = entry.value;

            // Downsample nếu điểm quá nhiều (>200 điểm/đường) để giữ FPS 60
            int step = 1;
            if (path.length > 200) {
              step = (path.length / 200).ceil();
            }

            List<FlSpot> spots = [];
            for (int i = 0; i < path.length; i += step) {
              spots.add(FlSpot(i.toDouble(), path[i]));
            }
            // Đảm bảo có điểm cuối cùng
            if ((path.length - 1) % step != 0) {
               spots.add(FlSpot((path.length - 1).toDouble(), path.last));
            }

            return LineChartBarData(
              spots: spots,
              isCurved: false,
              color: colors[index % colors.length].withValues(alpha: 0.8),
              barWidth: 1.5,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            );
          }).toList(),
          lineTouchData: const LineTouchData(
            handleBuiltInTouches: true,
          ),
        ),
      ),
    );
  }
}
