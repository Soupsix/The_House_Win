import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../application/matches/match_provider.dart';
import '../../application/bets/bet_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/bet_choice.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_routes.dart';

class MatchDetailScreen extends ConsumerStatefulWidget {
  const MatchDetailScreen({super.key});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  BetChoice _selectedChoice = BetChoice.over;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onPlaceBet() async {
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    final match = ref.read(selectedMatchProvider);
    if (match == null) return;

    final odds = switch (_selectedChoice) {
      BetChoice.over => match.oddsOver,
      BetChoice.under => match.oddsUnder,
      BetChoice.draw => match.oddsDraw,
    };

    ref.read(betProvider.notifier).draftBet(match.id, _selectedChoice, amount, odds);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bạn cần đăng nhập tài khoản để đặt cược!'),
          backgroundColor: Colors.orange,
        ),
      );
      context.push(AppRoutes.login);
      return;
    }

    await ref.read(betProvider.notifier).confirmBet(user.uid);
    final betState = ref.read(betProvider);

    if (betState.errorMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(betState.errorMessage!), backgroundColor: Colors.red),
      );
    } else if (betState.successMessage != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(betState.successMessage!), backgroundColor: Colors.green),
      );
      _amountController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(selectedMatchProvider);

    if (match == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: Center(child: Text('Không tìm thấy trận đấu', style: TextStyle(color: Colors.white))),
      );
    }

    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    final isSubmitting = ref.watch(betProvider).isSubmitting;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: CustomScrollView(
        slivers: [
          // ── AppBar với gradient ──
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: const Color(0xFF16213E),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Chi tiết trận đấu',
              style: TextStyle(color: Colors.white, fontFamily: 'Inter', fontWeight: FontWeight.bold),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF0F3460), Color(0xFF16213E), Color(0xFF0D0D1A)],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 60, 16, 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // League badge
                        if (match.leagueName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE94560).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE94560).withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              match.leagueName,
                              style: const TextStyle(
                                  color: Color(0xFFE94560), fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        const SizedBox(height: 12),
                        // Teams row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Home team
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTeamLogo(match.homeTeamLogo),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.homeTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // Score
                            Column(
                              children: [
                                Text(
                                  '${match.scoreHome} - ${match.scoreAway}',
                                  style: const TextStyle(
                                      color: Color(0xFFFFB347),
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF00D4AA).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    dateFormat.format(match.utcDate),
                                    style: const TextStyle(
                                        color: Color(0xFF00D4AA), fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                            // Away team
                            Expanded(
                              child: Column(
                                children: [
                                  _buildTeamLogo(match.awayTeamLogo),
                                  const SizedBox(height: 8),
                                  Text(
                                    match.awayTeam,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Nội dung chính ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Kèo chọn
                _buildSectionTitle('CHỌN KÈO CÁ CƯỢC'),
                const SizedBox(height: 12),
                _buildBetChoicesCard(match),
                const SizedBox(height: 20),

                // Nhập tiền
                _buildSectionTitle('SỐ TIỀN CƯỢC'),
                const SizedBox(height: 12),
                _buildAmountInput(),
                const SizedBox(height: 8),
                // Quick amount buttons
                _buildQuickAmounts(),
                const SizedBox(height: 24),

                // Thông tin kết quả dự kiến
                if (_amountController.text.isNotEmpty) ...[
                  _buildPayoutPreview(match),
                  const SizedBox(height: 20),
                ],

                // Nút đặt cược
                _buildPlaceBetButton(isSubmitting),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String logoUrl) {
    if (logoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: logoUrl,
        width: 56,
        height: 56,
        errorWidget: (_, __, ___) => _defaultShield(),
        placeholder: (_, __) => _defaultShield(),
      );
    }
    return _defaultShield();
  }

  Widget _defaultShield() => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF1A4A8A), width: 2),
        ),
        child: const Icon(Icons.shield, color: Colors.white70, size: 28),
      );

  Widget _buildSectionTitle(String title) => Text(
        title,
        style: const TextStyle(
            color: Color(0xFFA0A0B0),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5),
      );

  Widget _buildBetChoicesCard(match) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A3060)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Mốc Tài/Xỉu: ${match.overUnderLine} bàn',
            style: const TextStyle(
                color: Color(0xFF00D4AA), fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  label: 'THẮNG',
                  sublabel: 'Home Win',
                  odds: match.oddsOver,
                  choice: BetChoice.over,
                  selectedColor: const Color(0xFF28DFB5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceButton(
                  label: 'HÒA',
                  sublabel: 'Draw',
                  odds: match.oddsDraw,
                  choice: BetChoice.draw,
                  selectedColor: const Color(0xFFFFB347),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildChoiceButton(
                  label: 'THUA',
                  sublabel: 'Away Win',
                  odds: match.oddsUnder,
                  choice: BetChoice.under,
                  selectedColor: const Color(0xFFE94560),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF1A3060)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildOddsInfo('TÀI (OVER)', 'x${match.oddsOver}', const Color(0xFF28DFB5)),
              _buildOddsInfo('MỐC', '${match.overUnderLine}', const Color(0xFFA0A0B0)),
              _buildOddsInfo('XỈU (UNDER)', 'x${match.oddsUnder}', const Color(0xFFE94560)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required String sublabel,
    required double odds,
    required BetChoice choice,
    required Color selectedColor,
  }) {
    final isSelected = _selectedChoice == choice;
    return GestureDetector(
      onTap: () => setState(() => _selectedChoice = choice),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFF2A3A5C),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? selectedColor : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                color: isSelected ? selectedColor.withValues(alpha: 0.7) : const Color(0xFF6A7A9A),
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? selectedColor : const Color(0xFF1A2A4A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x$odds',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFA0A0B0),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOddsInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6A7A9A), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1A3060)),
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          filled: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          hintText: '0',
          hintStyle: TextStyle(color: Colors.white24),
          suffixText: 'VNĐ',
          suffixStyle: TextStyle(color: Color(0xFF6A7A9A), fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildQuickAmounts() {
    final amounts = ['10,000', '50,000', '100,000', '500,000'];
    return Row(
      children: amounts.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _amountController.text = a.replaceAll(',', '');
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1D33),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1A3060)),
              ),
              child: Text(
                a,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF00D4AA), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayoutPreview(match) {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '')) ?? 0;
    final odds = switch (_selectedChoice) {
      BetChoice.over => match.oddsOver as double,
      BetChoice.under => match.oddsUnder as double,
      BetChoice.draw => match.oddsDraw as double,
    };
    final payout = amount * odds;
    final profit = payout - amount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D4AA).withValues(alpha: 0.1),
            const Color(0xFF0F3460).withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D4AA).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPayoutItem('Cược', '${amount.toStringAsFixed(0)} đ', Colors.white70),
          _buildPayoutItem('Hệ số', 'x$odds', const Color(0xFFFFB347)),
          _buildPayoutItem('Thắng được', '+${profit.toStringAsFixed(0)} đ', const Color(0xFF00D4AA)),
          _buildPayoutItem('Tổng nhận', '${payout.toStringAsFixed(0)} đ', const Color(0xFF28DFB5)),
        ],
      ),
    );
  }

  Widget _buildPayoutItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6A7A9A), fontSize: 10)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  Widget _buildPlaceBetButton(bool isSubmitting) {
    final choiceLabel = switch (_selectedChoice) {
      BetChoice.over => 'THẮNG (HOME WIN)',
      BetChoice.under => 'THUA (AWAY WIN)',
      BetChoice.draw => 'HÒA (DRAW)',
    };
    final choiceColor = switch (_selectedChoice) {
      BetChoice.over => const Color(0xFF28DFB5),
      BetChoice.under => const Color(0xFFE94560),
      BetChoice.draw => const Color(0xFFFFB347),
    };

    return GestureDetector(
      onTap: isSubmitting ? null : _onPlaceBet,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSubmitting
                ? [Colors.grey.shade800, Colors.grey.shade700]
                : [choiceColor, choiceColor.withValues(alpha: 0.7)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSubmitting
              ? []
              : [
                  BoxShadow(
                    color: choiceColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ],
        ),
        child: Center(
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
              : Text(
                  'ĐẶT CƯỢC NGAY · $choiceLabel',
                  style: const TextStyle(
                      color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }
}
