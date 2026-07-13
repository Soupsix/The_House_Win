import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/simulation/simulation_provider.dart';

class OddsInputCard extends ConsumerWidget {
  const OddsInputCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(simulationProvider);
    final notifier = ref.read(simulationProvider.notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3050)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TỶ LỆ CƯỢC (ODDS)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFFA0A0B0),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInput(
                  label: 'Cửa Tài (Over)',
                  value: state.oddsOver.toStringAsFixed(2),
                  onChanged: (val) {
                    final odds = double.tryParse(val);
                    if (odds != null && odds > 1) {
                      notifier.updateParams(oddsOver: odds);
                    }
                  },
                  color: const Color(0xFF00D4AA),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInput(
                  label: 'Cửa Xỉu (Under)',
                  value: state.oddsUnder.toStringAsFixed(2),
                  onChanged: (val) {
                    final odds = double.tryParse(val);
                    if (odds != null && odds > 1) {
                      notifier.updateParams(oddsUnder: odds);
                    }
                  },
                  color: const Color(0xFFE94560),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161825),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withValues(alpha: 0.5), width: 1.5),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
