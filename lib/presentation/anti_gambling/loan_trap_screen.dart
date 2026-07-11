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

    if (!showLoanTrap) {
      return const SizedBox.shrink();
    }

    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Hỗ trợ tài chính",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [

            const SizedBox(height: 30),

            const Icon(
              Icons.account_balance_wallet,
              color: Colors.amber,
              size: 90,
            ),

            const SizedBox(height: 25),

            const Text(
              "Bạn đã gần hết tiền!",
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Hệ thống có thể cho bạn vay thêm\n5.000.000 VNĐ để tiếp tục chơi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 17,
              ),
            ),

            const SizedBox(height: 30),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red),
              ),
              child: const Column(
                children: [

                  Icon(
                    Icons.warning_amber,
                    color: Colors.red,
                    size: 35,
                  ),

                  SizedBox(height: 10),

                  Text(
                    "Đây là tình huống mô phỏng nhằm giáo dục người chơi.\n"
                        "Đừng bao giờ vay tiền để gỡ cược ngoài đời thật.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.attach_money),
                label: const Text(
                  "VAY NGAY",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {

                  if (user == null) return;

                  await ref
                      .read(antiGamblingProvider.notifier)
                      .onLoanTrapClicked(user.uid);

                  if (!context.mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WarningScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}