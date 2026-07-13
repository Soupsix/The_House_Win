import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/simulation/simulation_provider.dart';
import 'widgets/monte_carlo_chart.dart';

class MonteCarloScreen extends ConsumerWidget {
  const MonteCarloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final notifier = ref.read(simulationProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'MÔ PHỎNG MONTE CARLO',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFFF5F5F5),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Phương pháp Monte Carlo sử dụng lấy mẫu ngẫu nhiên lặp đi lặp lại để tính toán và biểu diễn sự thay đổi số dư theo thời gian. Bạn sẽ thấy rõ tại sao "Cờ bạc chơi lâu tất thua".',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          // Config inputs
          Row(
            children: [
              Expanded(
                child: _buildConfigInput(
                  label: 'Số trận cược',
                  value: state.numBets.toString(),
                  onChanged: (val) {
                    final num = int.tryParse(val);
                    if (num != null && num > 0) {
                      notifier.updateParams(numBets: num);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigInput(
                  label: 'Mức cược',
                  value: state.betAmount.toStringAsFixed(0),
                  onChanged: (val) {
                    final amount = double.tryParse(val);
                    if (amount != null && amount > 0) {
                      notifier.updateParams(betAmount: amount);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildConfigInput(
                  label: 'Số đường (paths)',
                  value: state.numPaths.toString(),
                  onChanged: (val) {
                    final num = int.tryParse(val);
                    if (num != null && num > 0 && num <= 10) {
                      notifier.updateParams(numPaths: num);
                    }
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Nút chạy mô phỏng
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: state.isRunning
                  ? null
                  : () {
                      notifier.runSimulation();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: const Color(0xFFE94560).withValues(alpha: 0.5),
              ),
              child: state.isRunning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'CHẠY MÔ PHỎNG',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 1.2,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(height: 24),
          const MonteCarloChart(),
          
          if (state.lastResult != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2030),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E3050)),
              ),
              child: Column(
                children: [
                  const Text(
                    'THỐNG KÊ KẾT QUẢ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFFFBBF24),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatBox('Cháy túi', '${state.lastResult!.bustCount}/${state.numPaths}', const Color(0xFFE94560)),
                      _buildStatBox('Có lãi', '${state.lastResult!.profitCount}/${state.numPaths}', const Color(0xFF00D4AA)),
                    ],
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildConfigInput({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 11,
            color: Color(0xFF9CA3AF),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        TextFormField(
          initialValue: value,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFFF5F5F5),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161825),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }
}
