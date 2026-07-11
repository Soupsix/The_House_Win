import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/anti_gambling/anti_gambling_provider.dart';
import 'widgets/education_content_card.dart';

class WarningScreen extends ConsumerWidget {
  const WarningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final antiGamblingState = ref.watch(antiGamblingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF120D14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF120D14),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text(
          'Cảnh báo rủi ro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B111A),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE94560),
                    width: 2,
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 86,
                      color: Color(0xFFE94560),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'DỪNG LẠI!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    SizedBox(height: 14),
                    Text(
                      'Bạn vừa nhấn vào một bẫy vay vốn giả lập.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Khi số dư thấp, cảm giác muốn vay tiền để gỡ lại khoản đã thua là một phản ứng tâm lý nguy hiểm. Việc tiếp tục cược không làm xác suất thắng tăng lên.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 14,
                        color: Color(0xFFD0C4C8),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Hệ thống đã ghi nhận hành vi này',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Số lần nhấn bẫy vay vốn trong phiên: '
                          '${antiGamblingState.loanTrapClickCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 14,
                        color: Color(0xFFA0A0B0),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const EducationContentCard(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(antiGamblingProvider.notifier)
                        .dismissWarning();

                    Navigator.of(context).popUntil(
                          (route) => route.isFirst,
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text(
                    'TÔI ĐÃ HIỂU',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA),
                    foregroundColor: const Color(0xFF10131A),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}