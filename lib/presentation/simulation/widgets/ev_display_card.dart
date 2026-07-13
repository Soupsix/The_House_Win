import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/simulation/simulation_provider.dart';
import '../../../application/simulation/simulation_state.dart';

class EvDisplayCard extends ConsumerWidget {
  const EvDisplayCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final houseEdge = state.calculatedHouseEdge;
    final ev = state.calculatedEV;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE94560).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE94560), size: 20),
              const SizedBox(width: 8),
              const Text(
                'LỢI THẾ NHÀ CÁI (HOUSE EDGE)',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFFE94560),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStat(
                  label: 'House Edge',
                  value: '${houseEdge.toStringAsFixed(2)}%',
                  color: const Color(0xFFE94560),
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFF2E3050)),
              Expanded(
                child: _buildStat(
                  label: 'Expected Value (EV)',
                  value: ev.toStringAsFixed(3),
                  color: const Color(0xFFFBBF24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE94560).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Với mỗi 1 đồng bạn cược, bạn được dự kiến sẽ mất trung bình ${ev.abs().toStringAsFixed(3)} đồng về lâu dài. Nhà cái luôn có lợi thế toán học.',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: Color(0xFFFCA5A5),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String label,
    required String value,
    required Color color,
  }) {
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
