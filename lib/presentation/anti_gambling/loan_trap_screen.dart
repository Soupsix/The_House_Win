import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/anti_gambling/anti_gambling_provider.dart';
import '../../application/auth/auth_provider.dart';
import 'warning_screen.dart';

class LoanTrapScreen extends ConsumerWidget {
  const LoanTrapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showLoanTrap = ref.watch(showLoanTrapProvider);
    final user = ref.watch(currentUserProvider);

    if (!showLoanTrap) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Hỗ trợ tài chính',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 36,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.amber,
                      size: 82,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Bạn đã gần hết tiền!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Hệ thống có thể cho bạn vay thêm\n'
                      '5.000.000 VNĐ để tiếp tục chơi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),

                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.attach_money),
                        label: const Text(
                          'VAY NGAY',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: user == null
                            ? null
                            : () async {
                                await ref
                                    .read(
                                      antiGamblingProvider.notifier,
                                    )
                                    .onLoanTrapClicked(user.uid);

                                if (!context.mounted) {
                                  return;
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const WarningScreen(),
                                  ),
                                );
                              },
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Không vay, quay lại',
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
