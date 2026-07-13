import 'package:flutter/material.dart';
import '../../../domain/models/slot_result_model.dart';
import '../../../core/utils/format_utils.dart';

class SlotHistoryList extends StatelessWidget {
  final List<SlotResultModel> history;

  const SlotHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có lịch sử quay.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        final isWin = result.payout > 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2030),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isWin ? const Color(0xFF00D4AA).withValues(alpha: 0.3) : const Color(0xFF2E3050),
            ),
          ),
          child: Row(
            children: [
              // Result Symbols
              Row(
                children: result.reelSymbolIds.map((symbolId) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF2E3050)),
                    ),
                    child: Center(
                      child: Text(
                        symbolId.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              // Details
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isWin ? '+${FormatUtils.formatCurrency(result.payout)}' : 'Trượt',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      color: isWin ? const Color(0xFF00D4AA) : Colors.white54,
                    ),
                  ),
                  if (isWin)
                    Text(
                      'x${result.multiplier}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFFFB347), // warning / odds color
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
