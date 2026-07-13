import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../matches/matches_screen.dart';
import '../betting/bet_screen.dart';
import '../spin_wheel/screens/spin_wheel_screen.dart';
import '../slot_machine/screens/slot_machine_screen.dart';
import '../simulation/simulation_screen.dart';
import '../../application/wallet/wallet_provider.dart';

// Màn hình Sàn Đấu tổng hợp — cho phép chọn giữa Trận Đấu (Bóng đá), Tài Xỉu và Vòng Quay
class ArenasScreen extends ConsumerStatefulWidget {
  const ArenasScreen({super.key});

  @override
  ConsumerState<ArenasScreen> createState() => _ArenasScreenState();
}

class _ArenasScreenState extends ConsumerState<ArenasScreen>
    with SingleTickerProviderStateMixin {
  int _selectedGame = 0; // 0: Trận Đấu, 1: Tài Xỉu

  List<_GameMode> _getGameModes(bool isBroke) {
    return [
      const _GameMode(
        id: 'match',
        title: 'Trận Đấu',
        subtitle: 'Cược theo kèo bóng đá',
        icon: Icons.sports_soccer,
        gradient: [Color(0xFF0F3460), Color(0xFF16213E)],
        accentColor: Color(0xFFE94560),
        badgeText: 'LIVE',
      ),
      const _GameMode(
        id: 'taixin',
        title: 'Tài Xỉu',
        subtitle: 'Mini-game 60 giây',
        icon: Icons.casino,
        gradient: [Color(0xFF2D0845), Color(0xFF1A1A2E)],
        accentColor: Color(0xFF7B2FBE),
        badgeText: 'HOT',
      ),
      const _GameMode(
        id: 'spinwheel',
        title: 'Vòng Quay',
        subtitle: 'Thử vận may',
        icon: Icons.pie_chart_outline,
        gradient: [Color(0xFFB8860B), Color(0xFF1A1A2E)],
        accentColor: Colors.amber,
        badgeText: 'NEW',
      ),
      const _GameMode(
        id: 'slotmachine',
        title: 'Slot Machine',
        subtitle: 'Nổ hũ rinh vàng',
        icon: Icons.casino_outlined,
        gradient: [Color(0xFF004D40), Color(0xFF1A1A2E)],
        accentColor: Color(0xFF00D4AA),
        badgeText: 'HOT',
      ),
      if (isBroke)
        const _GameMode(
          id: 'simulation',
          title: 'Mô phỏng',
          subtitle: 'Mô phỏng Monte Carlo',
          icon: Icons.analytics,
          gradient: [Color(0xFF3F51B5), Color(0xFF1A1A2E)],
          accentColor: Color(0xFF5C6BC0),
          badgeText: 'PRO',
        ),
    ];
  }
  @override
  Widget build(BuildContext context) {
    final isBroke = ref.watch(walletProvider).isBroke;
    final gameModes = _getGameModes(isBroke);
    
    // Clamp selected game to valid index safely
    int currentSelected = _selectedGame;
    if (currentSelected >= gameModes.length) {
      currentSelected = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _selectedGame = 0);
      });
    }

    final currentGameId = gameModes[currentSelected].id;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
          // Header + Game Selector
          _buildHeader(context, gameModes, currentSelected),

          // Divider
          const SizedBox(height: 1),

          // Content — switch giữa các màn hình dựa theo id
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildCurrentScreen(currentGameId),
            ),
          ),
        ],
      ),

      ),
    );
  }

  Widget _buildCurrentScreen(String id) {
    switch (id) {
      case 'match':
        return const MatchesScreen(key: ValueKey('matches'));
      case 'taixin':
        return const BetScreen(key: ValueKey('taixin'));
      case 'spinwheel':
        return const SpinWheelScreen(key: ValueKey('spinwheel'));
      case 'slotmachine':
        return const SlotMachineScreen(key: ValueKey('slotmachine'));
      case 'simulation':
        return const SimulationScreen(key: ValueKey('simulation'));
      default:
        return const MatchesScreen(key: ValueKey('matches'));
    }
  }

  // Header với game selector dạng dropdown
  Widget _buildHeader(BuildContext context, List<_GameMode> gameModes, int currentSelected) {
    final currentGame = gameModes[currentSelected];
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        child: Row(
          children: [
            const Icon(
              Icons.stadium,
              color: Color(0xFFE94560),
              size: 22,
            ),
            const SizedBox(width: 8),
            const Text(
              'SÀN ĐẤU',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFFF5F5F5),
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            // Dropdown chọn game
            PopupMenuButton<int>(
              onSelected: (index) {
                if (_selectedGame != index) {
                  setState(() => _selectedGame = index);
                }
              },
              offset: const Offset(0, 48),
              color: const Color(0xFF1E2030),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Color(0xFF2E3050)),
              ),
              itemBuilder: (context) => gameModes.asMap().entries.map((entry) {
                final index = entry.key;
                final game = entry.value;
                final isSelected = currentSelected == index;
                return PopupMenuItem<int>(
                  value: index,
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? game.accentColor.withValues(alpha: 0.2)
                              : const Color(0xFF252840),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(game.icon, size: 18,
                          color: isSelected ? game.accentColor : const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? const Color(0xFFF5F5F5) : const Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            game.subtitle,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              color: isSelected ? const Color(0xFFA0A0B0) : const Color(0xFF4B5265),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: game.accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game.badgeText,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: game.accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: currentGame.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: currentGame.accentColor.withValues(alpha: 0.6),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(currentGame.icon, size: 18, color: currentGame.accentColor),
                    const SizedBox(width: 8),
                    Text(
                      currentGame.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 20, color: currentGame.accentColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

// Data class cho game mode
class _GameMode {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accentColor;
  final String badgeText;

  const _GameMode({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accentColor,
    required this.badgeText,
  });
}
