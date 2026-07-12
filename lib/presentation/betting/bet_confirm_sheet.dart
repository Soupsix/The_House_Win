import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/bets/dice_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/enums/bet_choice.dart';

// Bottom sheet xác nhận đặt cược Tài Xỉu
class BetConfirmSheet extends ConsumerWidget {
  const BetConfirmSheet({super.key});

  // Format hiển thị số tiền dạng "50.000 đ"
  String _formatBalance(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(2)}M';
    }
    final s = value.toStringAsFixed(0);
    final result = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) result.write('.');
      result.write(s[i]);
    }
    return '${result.toString()} đ';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final betState = ref.watch(diceProvider);
    final draft = betState.currentDraft;
    final isSubmitting = betState.isSubmitting;
    final sessionStatus = betState.sessionStatus;

    if (draft == null) {
      return const SizedBox.shrink();
    }

    final isLocked = sessionStatus == SessionStatus.locked;
    final isSettled = sessionStatus == SessionStatus.settled;
    final isChoiceOver = draft.choice == BetChoice.over;

    // Lắng nghe khi đặt cược thành công để tự động tắt bottom sheet
    ref.listen<String?>(
      diceProvider.select((s) => s.successMessage),
      (previous, next) {
        if (next != null && (next.contains('thành công') || next.contains('Đặt cược'))) {
          Navigator.of(context).pop();
        }
      },
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E2020),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Color(0xFF5A4042), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'XÁC NHẬN ĐẶT CƯỢC',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFA0A0B0),
                    letterSpacing: 1.2,
                  ),
                ),
                IconButton(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          ref.read(diceProvider.notifier).cancelDraft();
                          Navigator.of(context).pop();
                        },
                  icon: const Icon(Icons.close, color: Color(0xFFA0A0B0)),
                ),
              ],
            ),
            const Divider(color: Color(0xFF333535), height: 20),

            // Chi tiết cược nháp
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121414),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF333535)),
              ),
              child: Column(
                children: [
                  // Lựa chọn Tài/Xỉu
                  _buildDetailRow(
                    'Lựa chọn',
                    isChoiceOver ? '🔴 TÀI' : '🟢 XỈU',
                    valueColor: isChoiceOver ? const Color(0xFFFC536D) : const Color(0xFF00D4AA),
                    valueWeight: FontWeight.w800,
                  ),
                  const SizedBox(height: 12),
                  // Tỷ lệ odds
                  _buildDetailRow(
                    'Tỷ lệ cược',
                    '×${draft.oddsAtTime.toStringAsFixed(2)}',
                    valueColor: const Color(0xFFFFB347),
                    valueWeight: FontWeight.w700,
                  ),
                  const SizedBox(height: 12),
                  // Tiền cược
                  _buildDetailRow(
                    'Số tiền cược',
                    _formatBalance(draft.amount),
                    valueColor: Colors.white,
                  ),
                  const Divider(color: Color(0xFF333535), height: 24),
                  // Payout dự kiến
                  _buildDetailRow(
                    'Trả thưởng tối đa',
                    _formatBalance(draft.potentialPayout),
                    valueColor: const Color(0xFF00D4AA),
                    valueWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Nút bấm đặt cược
            ElevatedButton(
              onPressed: (isLocked || isSettled || isSubmitting)
                  ? null
                  : () async {
                      final user = ref.read(currentUserProvider);
                      if (user != null) {
                        await ref.read(diceProvider.notifier).confirmBet(user.uid);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isChoiceOver ? const Color(0xFFFC536D) : const Color(0xFF00D4AA),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF4B5265),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLocked ? 'ĐÃ KHÓA CƯỢC' : 'XÁC NHẬN ĐẶT',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget dòng chi tiết
  Widget _buildDetailRow(
    String label,
    String value, {
    Color valueColor = Colors.white,
    FontWeight valueWeight = FontWeight.w600,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFA0A0B0),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: fontSize,
            fontWeight: valueWeight,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
