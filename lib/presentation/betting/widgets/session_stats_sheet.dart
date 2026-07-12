import 'package:flutter/material.dart';
import '../../../domain/models/betting_session_model.dart';

// Bottom sheet thống kê 10 phiên gần nhất (biểu đồ + checkbox xúc xắc)
class SessionStatsSheet extends StatefulWidget {
  final List<BettingSessionModel> sessions;

  const SessionStatsSheet({super.key, required this.sessions});

  @override
  State<SessionStatsSheet> createState() => _SessionStatsSheetState();
}

class _SessionStatsSheetState extends State<SessionStatsSheet> {
  bool _showDice1 = true;
  bool _showDice2 = true;
  bool _showDice3 = false;

  // Phiên theo thứ tự cũ → mới (để biểu đồ đọc từ trái qua phải)
  List<BettingSessionModel> get _ordered =>
      widget.sessions.reversed.toList();

  @override
  Widget build(BuildContext context) {
    final sessions = _ordered;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1C1C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF444444),
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    color: Color(0xFFFC536D), size: 20),
                SizedBox(width: 8),
                Text(
                  'Thống kê 10 phiên gần nhất',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Chưa có dữ liệu phiên nào',
                style: TextStyle(color: Color(0xFFA0A0B0)),
              ),
            )
          else ...[
            // ── Biểu đồ kết quả Tài/Xỉu ──
            _buildResultChart(sessions),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'THEO DÕI XÚC XẮC',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFA0A0B0),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Checkboxes xúc xắc
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildDiceCheckbox('Xúc xắc 1', const Color(0xFFFC536D),
                      _showDice1, (v) => setState(() => _showDice1 = v!)),
                  const SizedBox(width: 12),
                  _buildDiceCheckbox('Xúc xắc 2', const Color(0xFF00D4AA),
                      _showDice2, (v) => setState(() => _showDice2 = v!)),
                  const SizedBox(width: 12),
                  _buildDiceCheckbox('Xúc xắc 3', const Color(0xFFFFB347),
                      _showDice3, (v) => setState(() => _showDice3 = v!)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Line chart xúc xắc
            if (_showDice1 || _showDice2 || _showDice3)
              _buildDiceLineChart(sessions),

            const SizedBox(height: 16),
          ],

          // Safe area bottom
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  // Biểu đồ cột kết quả Tài/Xỉu 10 phiên
  Widget _buildResultChart(List<BettingSessionModel> sessions) {
    final overCount = sessions.where((s) => s.result == 'over').length;
    final underCount = sessions.where((s) => s.result == 'under').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tiến trình Tài/Xỉu tổng quát
          Row(
            children: [
              Expanded(
                flex: overCount.clamp(1, 10),
                child: Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFC536D),
                    borderRadius:
                        BorderRadius.horizontal(left: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      'TÀI $overCount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: underCount.clamp(1, 10),
                child: Container(
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00D4AA),
                    borderRadius:
                        BorderRadius.horizontal(right: Radius.circular(8)),
                  ),
                  child: Center(
                    child: Text(
                      'XỈU $underCount',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Cột mini từng phiên
          SizedBox(
            height: 90,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(sessions.length, (i) {
                final s = sessions[i];
                final isOver = s.result == 'over';
                final total = (s.dice1 + s.dice2 + s.dice3).clamp(3, 18);
                // label(12) + gap(2) + bar + gap(4) + session#(10) = 90
                // → bar tối đa = 62px khi total = 18
                final barHeight = ((total - 3) / 15 * 46 + 16).clamp(16.0, 62.0);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (total > 3)
                          Text(
                            '$total',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isOver
                                  ? const Color(0xFFFC536D)
                                  : const Color(0xFF00D4AA),
                            ),
                          ),
                        if (total > 3) const SizedBox(height: 2),
                        Container(
                          height: barHeight,
                          decoration: BoxDecoration(
                            color: isOver
                                ? const Color(0xFFFC536D)
                                : const Color(0xFF00D4AA),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '#${s.sessionNumber}',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 8,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // Checkbox style đẹp
  Widget _buildDiceCheckbox(
    String label,
    Color color,
    bool value,
    void Function(bool?) onChanged,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: value ? color.withValues(alpha: 0.15) : const Color(0xFF252727),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value ? color : const Color(0xFF3A3C3C),
              width: value ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                value ? Icons.check_box : Icons.check_box_outline_blank,
                color: value ? color : const Color(0xFF555555),
                size: 16,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: value ? color : const Color(0xFF777777),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Line chart giá trị từng xúc xắc qua 10 phiên
  Widget _buildDiceLineChart(List<BettingSessionModel> sessions) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: const Color(0xFF252727),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: CustomPaint(
          painter: _DiceLineChartPainter(
            sessions: sessions,
            showDice1: _showDice1,
            showDice2: _showDice2,
            showDice3: _showDice3,
            color1: const Color(0xFFFC536D),
            color2: const Color(0xFF00D4AA),
            color3: const Color(0xFFFFB347),
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

// CustomPainter vẽ line chart cho 3 xúc xắc
class _DiceLineChartPainter extends CustomPainter {
  final List<BettingSessionModel> sessions;
  final bool showDice1;
  final bool showDice2;
  final bool showDice3;
  final Color color1;
  final Color color2;
  final Color color3;

  _DiceLineChartPainter({
    required this.sessions,
    required this.showDice1,
    required this.showDice2,
    required this.showDice3,
    required this.color1,
    required this.color2,
    required this.color3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (sessions.isEmpty) return;

    final n = sessions.length;
    const minVal = 1.0;
    const maxVal = 6.0;

    // Đường lưới ngang (1-6)
    final gridPaint = Paint()
      ..color = const Color(0xFF333535)
      ..strokeWidth = 0.5;
    for (int v = 1; v <= 6; v++) {
      final y = size.height - ((v - minVal) / (maxVal - minVal)) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Nhãn Y-axis
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int v = 1; v <= 6; v++) {
      final y = size.height - ((v - minVal) / (maxVal - minVal)) * size.height;
      tp.text = TextSpan(
        text: '$v',
        style: const TextStyle(
          color: Color(0xFF555555),
          fontSize: 9,
          fontFamily: 'Inter',
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(0, y - 5));
    }

    // Vẽ từng line
    void drawLine(List<int> values, Color color) {
      if (values.every((v) => v == 0)) return; // không có dữ liệu
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path();
      bool started = false;

      for (int i = 0; i < n; i++) {
        final v = values[i];
        if (v == 0) continue;

        final xStep = n > 1 ? size.width / (n - 1) : size.width / 2;
        final x = n > 1 ? i * xStep : size.width / 2;
        final y = size.height -
            ((v - minVal) / (maxVal - minVal)) * size.height;

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }

        canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
      }

      canvas.drawPath(path, paint);
    }

    final dice1Vals = sessions.map((s) => s.dice1).toList();
    final dice2Vals = sessions.map((s) => s.dice2).toList();
    final dice3Vals = sessions.map((s) => s.dice3).toList();

    if (showDice1) drawLine(dice1Vals, color1);
    if (showDice2) drawLine(dice2Vals, color2);
    if (showDice3) drawLine(dice3Vals, color3);
  }

  @override
  bool shouldRepaint(covariant _DiceLineChartPainter old) =>
      old.sessions != sessions ||
      old.showDice1 != showDice1 ||
      old.showDice2 != showDice2 ||
      old.showDice3 != showDice3;
}
