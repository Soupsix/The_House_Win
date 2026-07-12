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

// Màn hình Tài Xỉu Premium — giao diện đặt cược mini-game 60 giây
class BetScreen extends ConsumerStatefulWidget {
  const BetScreen({super.key});

  @override
  ConsumerState<BetScreen> createState() => _BetScreenState();
}

class _BetScreenState extends ConsumerState<BetScreen>
    with TickerProviderStateMixin {
  // Lựa chọn hiện tại: 'over' hoặc 'under'
  String _selectedChoice = 'over';

  // Mức cược đang chọn
  double _selectedChip = 50000;

  // Controller nhập tay
  final TextEditingController _amountController = TextEditingController();

  // Animation cho xúc xắc
  late AnimationController _diceAnimation;
  late Animation<double> _diceFloat;

  // Animation cho vòng đếm ngược
  late AnimationController _countdownAnimation;

  static const List<double> _chips = [
    1000, 5000, 10000, 50000, 100000, 500000, 1000000
  ];

  @override
  void initState() {
    super.initState();
    _amountController.text = '50.000';

    _diceAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _diceFloat = Tween<double>(begin: 0, end: -10).animate(
      CurvedAnimation(parent: _diceAnimation, curve: Curves.easeInOut),
    );

    _countdownAnimation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );

    // Khởi tạo BetNotifier khi user đăng nhập
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(betProvider.notifier).initialize(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _diceAnimation.dispose();
    _countdownAnimation.dispose();
    _amountController.dispose();
    super.dispose();
  }

  // Chọn chip mức cược
  void _selectChip(double value) {
    setState(() {
      _selectedChip = value;
    });

    final formatted = _formatAmount(value);
    _amountController.text = formatted;
  }

  // Format số tiền hiển thị (50000 → 50.000)
  String _formatAmount(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(value % 1000000 == 0 ? 0 : 1)}M';
    } else if (value >= 1000) {
      final k = value / 1000;
      return '${k.toStringAsFixed(k % 1 == 0 ? 0 : 1)}.000';
    }
    return value.toStringAsFixed(0);
  }

  // Format số tiền hiển thị đầy đủ (số dư ví)
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

  // Gửi lệnh đặt cược (mở bottom sheet xác nhận cược)
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

    // Draft cược
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

    // Mở Bottom Sheet xác nhận đặt cược
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const BetConfirmSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen để trigger màn hình kết quả hoặc lỗi khi có kết toán
    ref.listen<BetState>(betProvider, (previous, next) {
      if (next.successMessage != null && next.successMessage != previous?.successMessage) {
        if (next.successMessage!.contains('thắng') || next.successMessage!.contains('thành công')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: const Color(0xFF00D4AA),
            ),
          );
          if (next.successMessage!.contains('thắng')) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BetResultScreen(isWin: true)),
            );
          }
        }
      }
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        if (next.errorMessage!.contains('thua') || next.errorMessage!.contains('thất bại')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: const Color(0xFFFC536D),
            ),
          );
          if (next.errorMessage!.contains('thua')) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BetResultScreen(isWin: false)),
            );
          }
        }
      }
    });

    final countdown = ref.watch(countdownProvider);
    final sessionStatus = ref.watch(sessionStatusProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final walletState = ref.watch(walletProvider);
    final betState = ref.watch(betProvider);
    final isSubmitting = betState.isSubmitting;

    final isLocked = sessionStatus == SessionStatus.locked;
    final isSettled = sessionStatus == SessionStatus.settled;

    return Scaffold(
      backgroundColor: const Color(0xFF121414),
      body: Column(
        children: [
          // Session Info Bar
          _buildSessionBar(countdown, sessionStatus, activeSession),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dice animation area
                  _buildDiceArea(countdown, activeSession),

                  const SizedBox(height: 20),

                  // Tài / Xỉu selection cards
                  _buildChoiceCards(activeSession, ref.watch(currentSessionBetsProvider)),

                  const SizedBox(height: 20),

                  // Current session bets (hidden when empty)

                  // Amount selection chips
                  _buildChipSelector(walletState.availableBalance, isLocked || isSettled),

                  const SizedBox(height: 16),

                  // Place Bet Button
                  _buildBetButton(isLocked, isSettled, isSubmitting),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Thanh thông tin phiên + countdown
  Widget _buildSessionBar(
      int countdown, SessionStatus status, BettingSessionModel? session) {
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2020),
        border: Border(
          bottom: BorderSide(
            color: statusColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Session number
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
                      'ID: ${session.sessionId}',
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
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
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
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.history, color: Color(0xFFFFB2B7), size: 24),
                tooltip: 'Lịch sử cược của tôi',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MyBetsScreen()),
                  );
                },
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
        ],
      ),
    );
  }

  // Tạo xúc xắc dựa trên kết quả Tài/Xỉu để hiển thị thực tế
  List<int> _getDiceForResult(String? result) {
    if (result == 'over') {
      return [5, 4, 3]; // Tổng 12 -> TÀI
    } else if (result == 'under') {
      return [1, 2, 3]; // Tổng 6 -> XỈU
    }
    return [4, 2, 6]; // Trạng thái mặc định / đang lắc
  }

  // Khu vực xúc xắc
  Widget _buildDiceArea(int countdown, BettingSessionModel? session) {
    final dice = _getDiceForResult(session?.result);
    final total = dice[0] + dice[1] + dice[2];

    return AnimatedBuilder(
      animation: _diceFloat,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _diceFloat.value),
          child: child,
        );
      },
      child: Center(
        child: Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF1E2020),
            border: Border.all(color: const Color(0xFF5A4042), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFC536D).withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Xúc xắc
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDie(dice[0], rotation: -0.15),
                  const SizedBox(width: 8),
                  _buildDie(dice[1], rotation: 0.2),
                  const SizedBox(width: 8),
                  _buildDie(dice[2], rotation: -0.1),
                ],
              ),
              const SizedBox(height: 12),
              // Tổng điểm
              Text(
                'Tổng: $total',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE2E2E2),
                  letterSpacing: 1,
                ),
              ),
              // Kết quả nếu có
              if (session?.result != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                  decoration: BoxDecoration(
                    color: session!.result == 'over'
                        ? const Color(0xFFFC536D).withValues(alpha: 0.2)
                        : const Color(0xFF00D4AA).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    session.result == 'over' ? '🔴 TÀI' : '🟢 XỈU',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: session.result == 'over'
                          ? const Color(0xFFFC536D)
                          : const Color(0xFF00D4AA),
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

  // Xúc xắc đơn lẻ
  Widget _buildDie(int dots, {double rotation = 0}) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x55000000), blurRadius: 6, offset: Offset(2, 3)),
          ],
        ),
        child: Center(
          child: Text(
            _dotToEmoji(dots),
            style: const TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }

  String _dotToEmoji(int dots) {
    const emojis = ['⚀', '⚁', '⚂', '⚃', '⚄', '⚅'];
    return emojis[(dots - 1).clamp(0, 5)];
  }

  // Cards chọn Tài / Xỉu
  Widget _buildChoiceCards(
      BettingSessionModel? session, List<BetModel> sessionBets) {
    final overBets = sessionBets.where((b) => b.choice == BetChoice.over).fold(0.0, (s, b) => s + b.amount);
    final underBets = sessionBets.where((b) => b.choice == BetChoice.under).fold(0.0, (s, b) => s + b.amount);
    final totalPool = (session?.totalOverBets ?? 0) + (session?.totalUnderBets ?? 0);

    final overPct = totalPool > 0 ? ((session?.totalOverBets ?? 0) / totalPool * 100).round() : 50;
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
                    ? [BoxShadow(color: const Color(0xFF00D4AA).withValues(alpha: 0.2), blurRadius: 12)]
                    : [],
              ),
              child: Column(
                children: [
                  const Text(
                    'XỈU',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF00D4AA),
                    ),
                  ),
                  const Text(
                    '4–10',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '×${session?.oddsUnder.toStringAsFixed(2) ?? "1.95"}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB347),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: underPct / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF333535),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFF00D4AA)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$underPct%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFF00D4AA),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (underBets > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cược: ${_formatBalance(underBets)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFF00D4AA),
                      ),
                    ),
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
                    ? [BoxShadow(color: const Color(0xFFFC536D).withValues(alpha: 0.2), blurRadius: 12)]
                    : [],
              ),
              child: Column(
                children: [
                  const Text(
                    'TÀI',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFC536D),
                    ),
                  ),
                  const Text(
                    '11–17',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '×${session?.oddsOver.toStringAsFixed(2) ?? "1.85"}',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB347),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: overPct / 100,
                      minHeight: 4,
                      backgroundColor: const Color(0xFF333535),
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFFC536D)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$overPct%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: Color(0xFFFC536D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (overBets > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Cược: ${_formatBalance(overBets)}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Color(0xFFFC536D),
                      ),
                    ),
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
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Khả dụng: ${_formatBalance(balance)}',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Color(0xFFFC536D),
                fontWeight: FontWeight.w600,
              ),
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
                        ? [BoxShadow(color: const Color(0xFFFC536D).withValues(alpha: 0.4), blurRadius: 10)]
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
                            : const Color(0xFFA0A0B0),
                      ),
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

  // Nút đặt cược
  Widget _buildBetButton(bool isLocked, bool isSettled, bool isSubmitting) {
    final isDisabled = isLocked || isSettled || isSubmitting;
    String label;
    Color color;

    if (isSettled) {
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
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: 0,
                  ),
                ],
        ),
        child: Center(
          child: isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDisabled ? Colors.white54 : Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
        ),
      ),
    );
  }
}
