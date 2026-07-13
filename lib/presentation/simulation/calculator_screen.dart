import 'package:flutter/material.dart';
import 'widgets/odds_input_card.dart';
import 'widgets/ev_display_card.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'MÁY TÍNH XÁC SUẤT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFFF5F5F5),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bất kể bạn cược ở đâu, nhà cái luôn thiết lập tỷ lệ cược sao cho tổng xác suất của các cửa lớn hơn 100%. Phần chênh lệch đó chính là lợi nhuận chắc chắn của họ (House Edge).',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          const OddsInputCard(),
          const SizedBox(height: 24),
          const EvDisplayCard(),
        ],
      ),
    );
  }
}
