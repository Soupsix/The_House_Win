import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/format_utils.dart';
import '../../../application/spin_wheel/spin_wheel_provider.dart';
import '../../../application/spin_wheel/spin_wheel_state.dart';
import '../../../application/wallet/wallet_provider.dart';
import '../../../application/auth/auth_provider.dart';
import '../widgets/spin_wheel_painter.dart';
import '../widgets/spin_history_list.dart';

class SpinWheelScreen extends ConsumerStatefulWidget {
  const SpinWheelScreen({super.key});

  @override
  ConsumerState<SpinWheelScreen> createState() => _SpinWheelScreenState();
}

class _SpinWheelScreenState extends ConsumerState<SpinWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  double _currentRotation = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rotationAnimation =
        Tween<double>(begin: 0, end: 0).animate(_animationController);

    _animationController.addListener(() {
      setState(() {});
    });

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentRotation = _rotationAnimation.value % (2 * pi);
        _isAnimating = false;
        ref.read(spinWheelProvider.notifier).onAnimationComplete();
        _showResultDialog();
        
        // Refresh wallet
        final user = ref.read(authProvider).user;
        if (user != null) {
          ref.read(walletProvider.notifier).loadWallet(user.uid);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).user;
      ref.read(spinWheelProvider.notifier).loadConfig();
      if (user != null) {
        ref.read(spinWheelProvider.notifier).loadHistory(user.uid);
        ref.read(walletProvider.notifier).loadWallet(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startSpin(String targetSegmentId) {
    if (_isAnimating) return;
    _isAnimating = true;

    final config = ref.read(spinWheelProvider).config;
    if (config == null) return;

    final segments = config.segments;
    final int segmentIndex =
        segments.indexWhere((s) => s.id == targetSegmentId);
    if (segmentIndex == -1) return;

    final N = segments.length;
    final sweepAngle = 2 * pi / N;
    final segmentCenterAngle = (segmentIndex * sweepAngle) + (sweepAngle / 2);
    // Pointer is at TOP (3 * pi / 2)
    final targetAngle = (3 * pi / 2) - segmentCenterAngle + (2 * pi * 10); // 10 full spins

    _rotationAnimation = Tween<double>(
      begin: _currentRotation,
      end: _currentRotation + targetAngle,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.decelerate,
    ));

    _animationController.forward(from: 0);
  }

  void _showResultDialog() {
    final result = ref.read(spinWheelProvider).lastResult;
    if (result == null) return;

    final isWin = result.payout > result.betAmount;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isWin ? 'Chúc Mừng!' : 'Rất Tiếc!',
          style: TextStyle(color: isWin ? Colors.green : Colors.red),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isWin
                  ? 'Bạn đã trúng x${result.multiplier}\nNhận được: ${FormatUtils.formatCurrency(result.payout)}'
                  : 'Vòng quay dừng lại ở x${result.multiplier}\nBạn đã mất ${FormatUtils.formatCurrency(result.betAmount)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showProbabilityTable() {
    final config = ref.read(spinWheelProvider).config;
    if (config == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Bảng Xác Suất Trúng Thưởng',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Trò chơi được thiết kế minh bạch. Xác suất được thiết lập tại Server.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...config.segments.map((s) {
              return ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(int.parse(s.colorHex.replaceFirst('#', 'FF'), radix: 16)),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(s.label, style: const TextStyle(color: Colors.white)),
                trailing: Text(
                  '${(s.probability * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đã hiểu'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(spinWheelProvider);
    final walletState = ref.watch(walletProvider);
    final user = ref.read(authProvider).user;

    ref.listen<SpinWheelState>(spinWheelProvider, (previous, next) {
      if (previous?.errorMessage != next.errorMessage && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!), backgroundColor: Colors.red),
        );
      }
      
      // Lắng nghe khi lastResult thay đổi và bắt đầu animation
      if (previous?.lastResult != next.lastResult && next.lastResult != null) {
        _startSpin(next.lastResult!.segmentId);
      }
    });

    if (state.isLoading && state.config == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.config == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(title: const Text('Vòng Quay May Mắn')),
        body: const Center(child: Text('Đang bảo trì.', style: TextStyle(color: Colors.white))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Vòng Quay May Mắn'),
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: _showProbabilityTable,
            tooltip: 'Xem Tỷ Lệ',
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Wallet Balance
            Text(
              'Số dư: ${FormatUtils.formatCurrency(walletState.balance - walletState.lockedAmount)}',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            
            // Spin Wheel Widget
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CustomPaint(
                    painter: SpinWheelPainter(
                      segments: state.config!.segments,
                      rotationAngle: _rotationAnimation.value,
                    ),
                  ),
                ),
                // Pointer
                Positioned(
                  top: 0,
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                // Center pin
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 4)],
                  ),
                )
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Bet Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Mức cược',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                            onPressed: state.isSpinning ? null : () {
                              ref.read(spinWheelProvider.notifier).setBetAmount(state.betAmount - 10000);
                            },
                          ),
                          Text(
                            FormatUtils.formatCurrency(state.betAmount),
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                            onPressed: state.isSpinning ? null : () {
                              ref.read(spinWheelProvider.notifier).setBetAmount(state.betAmount + 10000);
                            },
                          ),
                        ],
                      ),
                      Slider(
                        value: state.betAmount,
                        min: state.config!.minBet,
                        max: state.config!.maxBet,
                        divisions: ((state.config!.maxBet - state.config!.minBet) / 10000).round(),
                        onChanged: state.isSpinning ? null : (val) {
                          ref.read(spinWheelProvider.notifier).setBetAmount(val);
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            disabledBackgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                          onPressed: (state.isSpinning || _isAnimating) ? null : () {
                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vui lòng đăng nhập để chơi')),
                              );
                              return;
                            }
                            ref.read(spinWheelProvider.notifier).spin(user.uid);
                          },
                          child: Text(
                            state.isSpinning ? 'ĐANG QUAY...' : 'QUAY NGAY',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            const Text(
              'Lịch sử quay của bạn',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpinHistoryList(history: state.history),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
