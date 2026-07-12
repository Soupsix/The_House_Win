import 'package:flutter/material.dart';
import '../celebration/win_celebration_overlay.dart';
import '../celebration/lose_feedback_widget.dart';

// Màn hình hiển thị kết quả Thắng/Thua của phiên cược Tài Xỉu
class BetResultScreen extends StatefulWidget {
  final bool isWin;

  const BetResultScreen({super.key, required this.isWin});

  @override
  State<BetResultScreen> createState() => _BetResultScreenState();
}

class _BetResultScreenState extends State<BetResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.isWin ? const Color(0xFF00D4AA) : const Color(0xFFFC536D);
    final statusText = widget.isWin ? 'THẮNG LỚN' : 'RẤT TIẾC';
    final descText = widget.isWin
        ? 'Dự đoán của bạn hoàn toàn chính xác!\nXu thưởng đã được cộng vào ví ảo.'
        : 'May mắn chưa mỉm cười với bạn lần này.\nHãy tiếp tục thử lại ở phiên cược tiếp theo!';

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.9),
      body: Stack(
        children: [
          // Tích hợp animation overlay
          if (widget.isWin)
            const WinCelebrationOverlay()
          else
            const LoseFeedbackWidget(),

          // Nội dung kết quả
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2020),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withValues(alpha: 0.15),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Biểu tượng động thái
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor.withValues(alpha: 0.1),
                            border: Border.all(color: statusColor, width: 2),
                          ),
                          child: Icon(
                            widget.isWin ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                            size: 40,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Trạng thái cược
                        Text(
                          statusText,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Mô tả chi tiết
                        Text(
                          descText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Color(0xFFA0A0B0),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Nút xác nhận đóng
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'QUAY LẠI',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
