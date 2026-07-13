import 'package:flutter/material.dart';
import '../../../domain/models/spin_result_model.dart';
import '../../../core/utils/format_utils.dart';

class SpinHistoryList extends StatelessWidget {
  final List<SpinResultModel> history;

  const SpinHistoryList({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Chưa có lịch sử quay.', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final result = history[index];
        final isWin = result.payout > result.betAmount;
        final isLoss = result.payout < result.betAmount;

        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isWin ? Colors.green.withOpacity(0.2) : (isLoss ? Colors.red.withOpacity(0.2) : Colors.grey.withOpacity(0.2)),
              child: Icon(
                isWin ? Icons.arrow_upward : (isLoss ? Icons.arrow_downward : Icons.horizontal_rule),
                color: isWin ? Colors.green : (isLoss ? Colors.red : Colors.grey),
              ),
            ),
            title: Text(
              'Cược: ${FormatUtils.formatCurrency(result.betAmount)}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Hệ số: x${result.multiplier} - ${FormatUtils.formatDate(result.createdAt)}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  isLoss ? '-${FormatUtils.formatCurrency(result.betAmount)}' : '+${FormatUtils.formatCurrency(result.payout)}',
                  style: TextStyle(
                    color: isWin ? Colors.green : (isLoss ? Colors.red : Colors.grey),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
