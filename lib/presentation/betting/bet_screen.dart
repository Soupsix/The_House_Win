import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/bets/bet_provider.dart';
import '../../application/bets/bet_state.dart';
import '../../application/wallet/wallet_provider.dart';
import '../../application/wallet/wallet_state.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/session_status.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/enums/bet_choice.dart';
import 'bet_confirm_sheet.dart';
import 'bet_result_screen.dart';
import 'my_bets_screen.dart';
import 'widgets/session_stats_sheet.dart';

// Màn hình Tài Xỉu Premium — giao diện đặt cược mini-game 60 giây
class BetScreen extends ConsumerStatefulWidget {
  const BetScreen({super.key});

  @override
  ConsumerState<BetScreen> createState() => _BetScreenState();
}

class _BetScreenState extends ConsumerState<BetScreen>
    with TickerProviderStateMixin {
  String _selectedChoice = 'over';
  double _selectedChip = 50000;
  final TextEditingController _amountController = TextEditingController();

  // Animation float nhẹ cho vòng tròn xúc xắc
  late AnimationController _floatController;
  late Animation<double> _diceFloat;

  // Animation lắc xúc xắc mượt mà (rung ngang)
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // Animation countdown vòng
  late AnimationController _countdownAnimation;

  // ─── Rolling state ───
  bool _isRolling = false;
  List<int> _rollingDice = [4, 2, 6];
  Timer? _rollingTimer;

  // Xúc xắc kết quả thật (sau khi rolling xong)
  List<int>? _revealedDice;
  String? _revealedResult;

  // Thông báo thắng/thua pending (delay đến khi rolling xong)
  _PendingNotification? _pendingNotification;

  static const List<double> _chips = [
    1000, 5000, 10000, 50000, 100000, 500000, 1000000
  ];

  // Thời gian rolling (giây)
  static const int _rollingSeconds = 4;

  @override
  void initState() {
    super.initState();
    _amountController.text = '50.000';

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _diceFloat = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Animation lắc xúc xắc: rung trái - phải liên tục khi rolling
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _shakeAnimation = Tween<double>(begin: -7.0, end: 7.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );

    _countdownAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(betProvider.notifier).initialize(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shakeController.dispose();
    _countdownAnimation.dispose();
    _amountController.dispose();
    _rollingTimer?.cancel();
    super.dispose();
  }

  // ─── Khởi động rolling animation 4 giây ───
  void _startRolling() {
    if (_isRolling) return;
    setState(() {
      _isRolling = true;
      _revealedDice = null;
      _revealedResult = null;
    });

    _rollingTimer?.cancel();

    // Bắt đầu animation lắc mượt mà
    _shakeController.repeat(reverse: true);

    // Đổi xúc xắc random mỗi 80ms (nhanh và mượt hơn)
    _rollingTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (mounted) {
        setState(() {
          _rollingDice = [
            Random().nextInt(6) + 1,
            Random().nextInt(6) + 1,
            Random().nextInt(6) + 1,
          ];
        });
      }
    });

    // Sau _rollingSeconds giây: dừng, hiển thị kết quả thật
    Timer(const Duration(seconds: _rollingSeconds), () {
      _rollingTimer?.cancel();
      _shakeController.stop();
      _shakeController.reset();
      if (!mounted) return;

      // Lấy kết quả thật từ recent sessions
      final recent = ref.read(recentSessionsProvider).valueOrNull;
      List<int> finalDice = [1, 3, 2];
      String? finalResult;

      if (recent != null && recent.isNotEmpty) {
        final latest = recent.first;
        if (latest.dice1 > 0) {
          finalDice = [latest.dice1, latest.dice2, latest.dice3];
        }
        finalResult = latest.result;
      }

      setState(() {
        _isRolling = false;
        _revealedDice = finalDice;
        _revealedResult = finalResult;
      });

      // Sau khi dừng 0.5 giây, show thông báo thắng/thua
      Future.delayed(const Duration(milliseconds: 500), () {
        _flushPendingNotification();
      });
    });
  }

  // Gửi thông báo thắng/thua sau khi rolling kết thúc
  void _flushPendingNotification() {
    if (!mounted) return;
    final pending = _pendingNotification;
    if (pending == null) return;
    _pendingNotification = null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pending.message),
        backgroundColor: pending.isWin
            ? const Color(0xFF00D4AA)
            : const Color(0xFFFC536D),
      ),
    );

    if (pending.isWin) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BetResultScreen(isWin: true)),
      );
    } else if (pending.isLoss) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const BetResultScreen(isWin: false)),
      );
    }
  }

  void _selectChip(double value) {
    setState(() => _selectedChip = value);
    _amountController.text = _formatAmount(value);
  }

  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}.000';
    }
    return value.toStringAsFixed(0);
  }

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

  void _placeBet() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập để đặt cược'),
          backgroundColor: Color(0xFFE94560),
        ),
      );
      return;
    }

    final sessionStatus = ref.read(sessionStatusProvider);
    if (sessionStatus != SessionStatus.open) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phiên cược đã khoá — chờ phiên mới'),
          backgroundColor: Color(0xFFFFB347),
        ),
      );
      return;
    }

    ref.read(betProvider.notifier).draftSessionBet(_selectedChoice, _selectedChip);

    final draftError = ref.read(betProvider).errorMessage;
    if (draftError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(draftError), backgroundColor: const Color(0xFFE94560)),
        );
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: const BetConfirmSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe BetState để bắt thắng/thua — nhưng delay nếu đang rolling
    ref.listen<BetState>(betProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        if (next.successMessage!.contains('thắng') || next.successMessage!.contains('thành công')) {
          if (_isRolling) {
            _pendingNotification = _PendingNotification(
              message: next.successMessage!,
              isWin: next.successMessage!.contains('thắng'),
              isLoss: false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.successMessage!), backgroundColor: const Color(0xFF00D4AA)),
            );
            if (next.successMessage!.contains('thắng')) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BetResultScreen(isWin: true)),
              );
            }
          }
        }
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        if (next.errorMessage!.contains('thua') || next.errorMessage!.contains('thất bại')) {
          if (_isRolling) {
            _pendingNotification = _PendingNotification(
              message: next.errorMessage!,
              isWin: false,
              isLoss: next.errorMessage!.contains('thua'),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(next.errorMessage!), backgroundColor: const Color(0xFFFC536D)),
            );
            if (next.errorMessage!.contains('thua')) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BetResultScreen(isWin: false)),
              );
            }
          }
        }
      }
    });

    // Lắng nghe sessionStatus để bắt thời điểm phiên kết thúc → bắt đầu rolling
    ref.listen<SessionStatus>(sessionStatusProvider, (previous, next) {
      if (previous != SessionStatus.settled && next == SessionStatus.settled) {
        if (!_isRolling) {
          _startRolling();
        }
      }
      // Reset khi phiên mới mở
      if (previous == SessionStatus.settled && next == SessionStatus.open) {
        setState(() {
          _revealedDice = null;
          _revealedResult = null;
          _pendingNotification = null;
        });
      }
    });

    final countdown = ref.watch(countdownProvider);
    final sessionStatus = ref.watch(sessionStatusProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final walletState = ref.watch(walletProvider);
    final betState = ref.watch(betProvider);
    final recentSessions = ref.watch(recentSessionsProvider).valueOrNull ?? [];
    final isSubmitting = betState.isSubmitting;
    final isLocked = sessionStatus == SessionStatus.locked;
    final isSettled = sessionStatus == SessionStatus.settled;

    return Scaffold(
      backgroundColor: const Color(0xFF121414),
      body: Column(
        children: [
          _buildSessionBar(countdown, sessionStatus, activeSession, recentSessions),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildDiceArea(activeSession),
                  const SizedBox(height: 20),
                  _buildChoiceCards(activeSession, ref.watch(currentSessionBetsProvider)),
                  const SizedBox(height: 20),
                  _buildChipSelector(walletState.availableBalance, isLocked || isSettled),
                  const SizedBox(height: 16),
                  _buildBetButton(isLocked, isSettled, isSubmitting),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Session Bar với 10 chấm lịch sử ───
  Widget _buildSessionBar(
    int countdown,
    SessionStatus status,
    BettingSessionModel? session,
    List<BettingSessionModel> recentSessions,
  ) {
    final isLocked = status == SessionStatus.locked;
    final isSettled = status == SessionStatus.settled;

    Color statusColor;
    String statusText;
    if (isSettled) {
      statusColor = const Color(0xFFA0A0B0);
      statusText = 'KẾT TOÁN';
    } else if (isLocked) {
      statusColor = const Color(0xFFFFB347);
      statusText = 'ĐANG KHÓA';
    } else {
      statusColor = const Color(0xFF00D4AA);
      statusText = 'ĐANG MỞ';
    }

    final pct = (countdown / 60.0).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2020),
        border: Border(
          bottom: BorderSide(color: statusColor.withValues(alpha: 0.3), width: 1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (session != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phiên #${session.sessionNumber}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'ID: ${session.sessionId.substring(0, 8)}...',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFFA0A0B0),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
              ],
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSettled)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Countdown circle
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 3,
                      backgroundColor: const Color(0xFF333535),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                    Text(
                      '$countdown',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.history, color: Color(0xFFFFB2B7), size: 24),
                tooltip: 'Lịch sử cược của tôi',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MyBetsScreen()),
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 3,
              backgroundColor: const Color(0xFF333535),
              valueColor: AlwaysStoppedAnimation<Color>(
                isLocked ? const Color(0xFFFFB347) : const Color(0xFF00D4AA),
              ),
            ),
          ),

          // ─── 10 chấm lịch sử phiên (cũ → mới: trái → phải) ───
          if (recentSessions.isNotEmpty) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _showStatsSheet(recentSessions),
              child: Row(
                children: [
                  const Text(
                    'Lịch sử: ',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF666666),
                    ),
                  ),
                  // Hiển thị từ phiên cũ nhất (trái) → mới nhất (phải/cuối)
                  ...recentSessions.reversed.map((s) => _buildHistoryDot(s)),
                  const Spacer(),
                  const Text(
                    'Thống kê',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF888888),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 14),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Chấm tròn lịch sử phiên: đỏ = Tài, xanh = Xỉu
  Widget _buildHistoryDot(BettingSessionModel session) {
    final isOver = session.result == 'over';
    final color = isOver ? const Color(0xFFFC536D) : const Color(0xFF00D4AA);
    return Container(
      margin: const EdgeInsets.only(right: 5),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4),
        ],
      ),
      child: Center(
        child: Text(
          isOver ? 'T' : 'X',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // Mở bottom sheet thống kê
  void _showStatsSheet(List<BettingSessionModel> sessions) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: SessionStatsSheet(sessions: sessions),
        ),
      ),
    );
  }

  // ─── Khu vực xúc xắc ───
  Widget _buildDiceArea(BettingSessionModel? session) {
    // Chọn xúc xắc hiển thị:
    // - Đang rolling: random dice
    // - Đã revealed: kết quả thật
    // - Bình thường: từ session hiện tại hoặc default
    List<int> displayDice;
    String? displayResult;

    if (_isRolling) {
      displayDice = _rollingDice;
      displayResult = null;
    } else if (_revealedDice != null) {
      displayDice = _revealedDice!;
      displayResult = _revealedResult;
    } else if (session != null && session.dice1 > 0) {
      displayDice = [session.dice1, session.dice2, session.dice3];
      displayResult = session.result;
    } else {
      displayDice = [4, 2, 6];
      displayResult = null;
    }

    return AnimatedBuilder(
      animation: _isRolling ? _shakeAnimation : _diceFloat,
      builder: (context, child) {
        return Transform.translate(
          offset: _isRolling
              ? Offset(_shakeAnimation.value, 0)
              : Offset(0, _diceFloat.value),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: 210,
          height: 210,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFF242828), Color(0xFF1A1C1C)],
              radius: 0.85,
            ),
            border: Border.all(
              color: _isRolling
                  ? const Color(0xFFFFB347)
                  : const Color(0xFF5A4042),
              width: _isRolling ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _isRolling
                    ? const Color(0xFFFFB347).withValues(alpha: 0.3)
                    : const Color(0xFFFC536D).withValues(alpha: 0.15),
                blurRadius: _isRolling ? 40 : 25,
                spreadRadius: _isRolling ? 8 : 3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Nhãn khi đang rolling
              if (_isRolling)
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '🎲 ĐANG LẮC...',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFFB347),
                      letterSpacing: 1,
                    ),
                  ),
                ),

              // Hàng 3 xúc xắc
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDie(displayDice[0], rotation: _isRolling ? 0.18 : -0.15),
                  const SizedBox(width: 8),
                  _buildDie(displayDice[1], rotation: _isRolling ? -0.12 : 0.2),
                  const SizedBox(width: 8),
                  _buildDie(displayDice[2], rotation: _isRolling ? 0.22 : -0.1),
                ],
              ),

              // Kết quả sau khi rolling xong
              if (!_isRolling && displayResult != null) ...[
                const SizedBox(height: 14),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) => Transform.scale(scale: v, child: child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                    decoration: BoxDecoration(
                      color: displayResult == 'over'
                          ? const Color(0xFFFC536D).withValues(alpha: 0.2)
                          : const Color(0xFF00D4AA).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: displayResult == 'over'
                            ? const Color(0xFFFC536D).withValues(alpha: 0.5)
                            : const Color(0xFF00D4AA).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      displayResult == 'over' ? '🔴  TÀI' : '🟢  XỈU',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: displayResult == 'over'
                            ? const Color(0xFFFC536D)
                            : const Color(0xFF00D4AA),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Xúc xắc đơn lẻ bằng CustomPaint ───
  Widget _buildDie(int dots, {double rotation = 0}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            const BoxShadow(
              color: Color(0x66000000),
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(-1, -1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: CustomPaint(
            painter: _DiceDotsPainter(dots: dots.clamp(1, 6)),
          ),
        ),
      ),
    );
  }

  // Cards chọn Tài / Xỉu
  Widget _buildChoiceCards(
      BettingSessionModel? session, List<BetModel> sessionBets) {
    final overBets = sessionBets
        .where((b) => b.choice == BetChoice.over)
        .fold(0.0, (s, b) => s + b.amount);
    final underBets = sessionBets
        .where((b) => b.choice == BetChoice.under)
        .fold(0.0, (s, b) => s + b.amount);
    final totalPool =
        (session?.totalOverBets ?? 0) + (session?.totalUnderBets ?? 0);
    final overPct = totalPool > 0
        ? ((session?.totalOverBets ?? 0) / totalPool * 100).round()
        : 50;
    final underPct = 100 - overPct;

    return Row(
      children: [
        // XỈU Card
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedChoice = 'under'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedChoice == 'under'
                      ? const Color(0xFF00D4AA)
                      : const Color(0xFF5A4042),
                  width: _selectedChoice == 'under' ? 2 : 1,
                ),
                boxShadow: _selectedChoice == 'under'
                    ? [
                        BoxShadow(
                            color: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                            blurRadius: 12)
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  const Text('XỈU',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00D4AA))),
                  const Text('4–10',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFFA0A0B0))),
                  const SizedBox(height: 8),
                  Text(
                    '×${session?.oddsUnder.toStringAsFixed(2) ?? "1.95"}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB347)),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: underPct / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF333535),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFF00D4AA)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$underPct%',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Color(0xFF00D4AA),
                          fontWeight: FontWeight.w600)),
                  if (underBets > 0) ...[
                    const SizedBox(height: 4),
                    Text('Cược: ${_formatBalance(underBets)}',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFF00D4AA))),
                  ],
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // TÀI Card
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedChoice = 'over'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2020),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedChoice == 'over'
                      ? const Color(0xFFFC536D)
                      : const Color(0xFF5A4042),
                  width: _selectedChoice == 'over' ? 2 : 1,
                ),
                boxShadow: _selectedChoice == 'over'
                    ? [
                        BoxShadow(
                            color: const Color(0xFFFC536D).withValues(alpha: 0.2),
                            blurRadius: 12)
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  const Text('TÀI',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFFC536D))),
                  const Text('11–17',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Color(0xFFA0A0B0))),
                  const SizedBox(height: 8),
                  Text(
                    '×${session?.oddsOver.toStringAsFixed(2) ?? "1.85"}',
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFB347)),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: overPct / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF333535),
                      valueColor:
                          const AlwaysStoppedAnimation(Color(0xFFFC536D)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$overPct%',
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Color(0xFFFC536D),
                          fontWeight: FontWeight.w600)),
                  if (overBets > 0) ...[
                    const SizedBox(height: 4),
                    Text('Cược: ${_formatBalance(overBets)}',
                        style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            color: Color(0xFFFC536D))),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Chips chọn mức cược
  Widget _buildChipSelector(double balance, bool disabled) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'CHỌN MỨC CƯỢC',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFA0A0B0),
                  letterSpacing: 1.2),
            ),
            Text(
              'Khả dụng: ${_formatBalance(balance)}',
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  color: Color(0xFFFC536D),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 58,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _chips.length,
            itemBuilder: (context, i) {
              final chip = _chips[i];
              final isSelected = _selectedChip == chip;
              return GestureDetector(
                onTap: disabled ? null : () => _selectChip(chip),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFFFC536D)
                        : const Color(0xFF1E2020),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFC536D)
                          : const Color(0xFF5A4042),
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                                color: const Color(0xFFFC536D)
                                    .withValues(alpha: 0.4),
                                blurRadius: 10)
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _chipLabel(chip),
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFA0A0B0)),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _chipLabel(double value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(0)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  Widget _buildBetButton(bool isLocked, bool isSettled, bool isSubmitting) {
    final isDisabled = isLocked || isSettled || isSubmitting || _isRolling;
    String label;
    Color color;

    if (_isRolling) {
      label = '⏳ Đang chờ kết quả...';
      color = const Color(0xFFFFB347);
    } else if (isSettled) {
      label = 'Chờ phiên mới...';
      color = const Color(0xFF4B5265);
    } else if (isLocked) {
      label = '🔒 Đã khoá cược';
      color = const Color(0xFFFFB347);
    } else if (isSubmitting) {
      label = 'Đang đặt...';
      color = const Color(0xFF6B7280);
    } else {
      label = _selectedChoice == 'over' ? '🔴  ĐẶT TÀI' : '🟢  ĐẶT XỈU';
      color = _selectedChoice == 'over'
          ? const Color(0xFFFC536D)
          : const Color(0xFF00D4AA);
    }

    return GestureDetector(
      onTap: isDisabled ? null : _placeBet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56,
        decoration: BoxDecoration(
          color: isDisabled ? color.withValues(alpha: 0.4) : color,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                      color: color.withValues(alpha: 0.4), blurRadius: 16),
                ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(
                  label,
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDisabled ? Colors.white54 : Colors.white,
                      letterSpacing: 0.8),
                ),
        ),
      ),
    );
  }
}

// ─── Model trung gian cho thông báo thắng/thua pending ───
class _PendingNotification {
  final String message;
  final bool isWin;
  final bool isLoss;
  _PendingNotification({
    required this.message,
    required this.isWin,
    required this.isLoss,
  });
}

// ─── CustomPainter vẽ chấm xúc xắc rõ nét ───
class _DiceDotsPainter extends CustomPainter {
  final int dots;
  _DiceDotsPainter({required this.dots});

  static const _dotColor = Color(0xFF1A1A1A);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = _dotColor;
    final r = size.width * 0.11; // bán kính chấm

    // Vị trí 9 ô (3x3 grid, tính theo tỉ lệ)
    final w = size.width;
    final h = size.height;
    final positions = {
      'tl': Offset(w * 0.18, h * 0.18),
      'tm': Offset(w * 0.50, h * 0.18),
      'tr': Offset(w * 0.82, h * 0.18),
      'ml': Offset(w * 0.18, h * 0.50),
      'mm': Offset(w * 0.50, h * 0.50),
      'mr': Offset(w * 0.82, h * 0.50),
      'bl': Offset(w * 0.18, h * 0.82),
      'bm': Offset(w * 0.50, h * 0.82),
      'br': Offset(w * 0.82, h * 0.82),
    };

    // Pattern chuẩn cho từng mặt xúc xắc
    final patterns = {
      1: ['mm'],
      2: ['tl', 'br'],
      3: ['tl', 'mm', 'br'],
      4: ['tl', 'tr', 'bl', 'br'],
      5: ['tl', 'tr', 'mm', 'bl', 'br'],
      6: ['tl', 'tr', 'ml', 'mr', 'bl', 'br'],
    };

    final keys = patterns[dots] ?? ['mm'];
    for (final key in keys) {
      final pos = positions[key];
      if (pos != null) {
        canvas.drawCircle(pos, r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DiceDotsPainter old) => old.dots != dots;
}
