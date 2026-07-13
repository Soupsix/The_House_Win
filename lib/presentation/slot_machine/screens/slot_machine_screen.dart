import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../application/slot_machine/slot_machine_provider.dart';
import '../../../application/auth/auth_provider.dart';
import '../../../application/wallet/wallet_provider.dart';
import '../../../application/wallet/wallet_state.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/models/slot_result_model.dart';
import '../widgets/slot_reel_widget.dart';
import '../widgets/slot_history_list.dart';

class SlotMachineScreen extends ConsumerStatefulWidget {
  const SlotMachineScreen({super.key});

  @override
  ConsumerState<SlotMachineScreen> createState() => _SlotMachineScreenState();
}

class _SlotMachineScreenState extends ConsumerState<SlotMachineScreen> {
  double _selectedBet = 10000.0;
  final List<double> _betOptions = [1000.0, 2000.0, 5000.0, 10000.0, 20000.0, 50000.0];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(slotMachineProvider.notifier).loadConfig();
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(slotMachineProvider.notifier).loadHistory(user.uid);
      }
    });
  }

  void _pull() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    final config = ref.read(slotMachineProvider).config;
    if (config == null) return;

    // The notifier and service handle deducting wallet inside a transaction.
    // However, the UI needs to be able to disable the button if balance is too low.
    ref.read(slotMachineProvider.notifier).pull(user.uid, _selectedBet);
  }

  void _showResultDialog(SlotResultModel result) {
    final netAmount = result.payout - result.betAmount;
    final isNetWin = netAmount > 0;
    final hasPayout = result.payout > 0;

    String titleText;
    Color titleColor;
    IconData titleIcon;
    String descriptionText;

    if (isNetWin) {
      titleText = 'THẮNG LỚN!';
      titleColor = Colors.amber;
      titleIcon = Icons.emoji_events;
      descriptionText = 'Chúc mừng! Bạn đã thắng x${result.multiplier.toStringAsFixed(1)} mức cược!';
    } else if (hasPayout) {
      titleText = 'KẾT QUẢ';
      titleColor = Colors.lightBlueAccent;
      titleIcon = Icons.stars;
      descriptionText = 'Bạn trúng thưởng nhỏ x${result.multiplier.toStringAsFixed(1)} và được hoàn lại một phần tiền cược.';
    } else {
      titleText = 'RẤT TIẾC';
      titleColor = Colors.grey;
      titleIcon = Icons.sentiment_dissatisfied;
      descriptionText = 'Lượt quay này không trúng thưởng.';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: titleColor.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        title: Row(
          children: [
            Icon(titleIcon, color: titleColor),
            const SizedBox(width: 8),
            Text(
              titleText,
              style: TextStyle(
                color: titleColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              descriptionText,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            
            // Detail Table
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E3050)),
              ),
              child: Column(
                children: [
                  _buildDialogRow('Mức cược:', FormatUtils.formatCurrency(result.betAmount), Colors.white70),
                  const SizedBox(height: 6),
                  _buildDialogRow(
                    'Nhận lại:', 
                    FormatUtils.formatCurrency(result.payout) + (hasPayout ? ' (x${result.multiplier})' : ''), 
                    hasPayout ? Colors.amber : Colors.white54
                  ),
                  const Divider(color: Color(0xFF2E3050), height: 16),
                  _buildDialogRow(
                    'Thay đổi ví:', 
                    '${netAmount >= 0 ? '+' : ''}${FormatUtils.formatCurrency(netAmount)}', 
                    netAmount >= 0 ? const Color(0xFF00D4AA) : Colors.redAccent,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Đóng',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(slotMachineProvider);
    final walletState = ref.watch(walletProvider);

    // Show error via snackbar or show result dialog / reload wallet when spin finishes
    ref.listen(slotMachineProvider, (prev, next) {
      if (prev?.errorMessage != next.errorMessage && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(slotMachineProvider.notifier).resetError();
      }

      if (prev != null && prev.isSpinning && !next.isSpinning && next.lastResult != null) {
        _showResultDialog(next.lastResult!);
        final user = ref.read(currentUserProvider);
        if (user != null) {
          ref.read(walletProvider.notifier).loadWallet(user.uid);
        }
      }
    });

    if (state.isLoading || state.config == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final config = state.config!;
    final canSpin = !state.isSpinning && walletState.availableBalance >= _selectedBet;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          // Wallet Balance
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2E3050)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Số dư khả dụng: ${FormatUtils.formatCurrency(walletState.balance - walletState.lockedAmount)}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Reels Area
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(config.reelCount, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: SlotReelWidget(
                    allSymbols: config.symbols,
                    isSpinning: state.isSpinning,
                    targetSymbolId: state.lastResult?.reelSymbolIds.length == config.reelCount 
                        ? state.lastResult!.reelSymbolIds[index] 
                        : null,
                    // Staggered stop: 300ms, 800ms, 1300ms
                    stopDelayMs: 300 + (index * 500),
                    onAnimationComplete: index == config.reelCount - 1
                        ? () => ref.read(slotMachineProvider.notifier).onAnimationComplete()
                        : null,
                  ),
                );
              }),
            ),
          ),

          // Bet Selection Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Chọn Mức Cược',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ),
          ),

          // Bet Selection Chips
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _betOptions.length,
              itemBuilder: (context, index) {
                final bet = _betOptions[index];
                final isSelected = _selectedBet == bet;
                final label = bet >= 1000 ? '${(bet / 1000).toStringAsFixed(0)}K' : bet.toString();
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(
                      label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFFE94560),
                    backgroundColor: const Color(0xFF16213E),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isSelected ? const Color(0xFFE94560) : const Color(0xFF2E3050),
                      ),
                    ),
                    onSelected: state.isSpinning
                        ? null
                        : (selected) {
                            if (selected) {
                              setState(() {
                                _selectedBet = bet;
                              });
                            }
                          },
                  ),
                );
              },
            ),
          ),

          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canSpin ? _pull : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE94560),
                  disabledBackgroundColor: const Color(0xFFE94560).withValues(alpha: 0.3),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  state.isSpinning ? 'ĐANG QUAY...' : 'QUAY',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Payout Table
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ExpansionTile(
              title: const Text('Bảng Trả Thưởng (Payout Table)', style: TextStyle(color: Colors.white)),
              iconColor: Colors.white,
              collapsedIconColor: Colors.white54,
              children: config.symbols.map((s) {
                final payouts = s.payoutTable.entries.map((e) => 'x${e.key}: ${e.value}').join(' | ');
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.id.toUpperCase(), style: const TextStyle(color: Colors.white)),
                      Text(payouts, style: const TextStyle(color: Color(0xFFFFB347))),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // History
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Lịch Sử Của Bạn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          SlotHistoryList(history: state.history),
        ],
      ),
    );
  }
}
