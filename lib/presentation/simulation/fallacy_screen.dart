import 'package:flutter/material.dart';
import 'dart:math';

class FallacyScreen extends StatefulWidget {
  const FallacyScreen({super.key});

  @override
  State<FallacyScreen> createState() => _FallacyScreenState();
}

class _FallacyScreenState extends State<FallacyScreen> {
  final Random _random = Random();
  bool _hasRevealed = false;
  String _userChoice = '';
  String _actualResult = '';
  
  // Lịch sử giả định để gài bẫy người chơi
  final List<String> _history = ['TÀI', 'TÀI', 'TÀI', 'TÀI', 'TÀI'];

  void _makeChoice(String choice) {
    setState(() {
      _userChoice = choice;
      _actualResult = _random.nextBool() ? 'TÀI' : 'XỈU';
      _hasRevealed = true;
    });
  }

  void _reset() {
    setState(() {
      _hasRevealed = false;
      _userChoice = '';
      _actualResult = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'HIỆU ỨNG TÂM LÝ (GAMBLER\'S FALLACY)',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: Color(0xFFF5F5F5),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ảo tưởng của người chơi cờ bạc là tin rằng các sự kiện độc lập trong quá khứ có thể ảnh hưởng đến kết quả tương lai.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF9CA3AF),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2030),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2E3050)),
            ),
            child: Column(
              children: [
                const Text(
                  'Lịch sử 5 ván gần nhất:',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _history.map((result) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00D4AA)),
                      ),
                      child: Text(
                        result,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4AA),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                
                if (!_hasRevealed) ...[
                  const Text(
                    'Đã ra TÀI 5 lần liên tiếp!\nTheo bạn, ván thứ 6 sẽ ra gì?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceButton('TÀI', const Color(0xFF00D4AA)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildChoiceButton('XỈU', const Color(0xFFE94560)),
                      ),
                    ],
                  ),
                ] else ...[
                  // Kết quả
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF161825),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'KẾT QUẢ VÁN 6: $_actualResult',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: _actualResult == 'TÀI' ? const Color(0xFF00D4AA) : const Color(0xFFE94560),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _userChoice == _actualResult ? 'Bạn đã đoán ĐÚNG!' : 'Bạn đã đoán SAI!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _userChoice == _actualResult ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Sự thật: Dù có ra TÀI 100 lần liên tiếp, thì xác suất ván tiếp theo vẫn luôn là 50% TÀI và 50% XỈU. Đồng xu không có trí nhớ.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: Color(0xFFA0A0B0),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _reset,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('THỬ LẠI', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String text, Color color) {
    return ElevatedButton(
      onPressed: () => _makeChoice(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    );
  }
}
