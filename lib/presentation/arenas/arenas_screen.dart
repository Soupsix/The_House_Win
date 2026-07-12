import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../matches/matches_screen.dart';
import '../betting/bet_screen.dart';

// Màn hình Sàn Đấu tổng hợp — cho phép chọn giữa Trận Đấu (Bóng đá) và Tài Xỉu
class ArenasScreen extends ConsumerStatefulWidget {
  const ArenasScreen({super.key});

  @override
  ConsumerState<ArenasScreen> createState() => _ArenasScreenState();
}

class _ArenasScreenState extends ConsumerState<ArenasScreen>
    with SingleTickerProviderStateMixin {
  int _selectedGame = 0; // 0: Trận Đấu, 1: Tài Xỉu

  final List<_GameMode> _gameModes = const [
    _GameMode(
      id: 'match',
      title: 'Trận Đấu',
      subtitle: 'Cược theo kèo bóng đá',
      icon: Icons.sports_soccer,
      gradient: [Color(0xFF0F3460), Color(0xFF16213E)],
      accentColor: Color(0xFFE94560),
      badgeText: 'LIVE',
    ),
    _GameMode(
      id: 'taixin',
      title: 'Tài Xỉu',
      subtitle: 'Mini-game 60 giây',
      icon: Icons.casino,
      gradient: [Color(0xFF2D0845), Color(0xFF1A1A2E)],
      accentColor: Color(0xFF7B2FBE),
      badgeText: 'HOT',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Column(
        children: [
          // Header + Game Selector
          _buildHeader(context),

          // Divider
          const SizedBox(height: 1),

          // Content — switch giữa 2 màn hình
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
              child: _selectedGame == 0
                  ? const MatchesScreen(key: ValueKey('matches'))
                  : const BetScreen(key: ValueKey('taixin')),
            ),
          ),
        ],
      ),
    );
  }

  // Header với game selector
  Widget _buildHeader(BuildContext context) {
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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
                // Chỉ số badge hiển thị game đang chọn
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _selectedGame == 0
                        ? const Color(0xFFE94560).withValues(alpha: 0.15)
                        : const Color(0xFF7B2FBE).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedGame == 0
                          ? const Color(0xFFE94560).withValues(alpha: 0.4)
                          : const Color(0xFF7B2FBE).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _selectedGame == 0
                              ? const Color(0xFFE94560)
                              : const Color(0xFF7B2FBE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _gameModes[_selectedGame].badgeText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _selectedGame == 0
                              ? const Color(0xFFE94560)
                              : const Color(0xFF7B2FBE),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Game mode selector — horizontal scrollable cards
          SizedBox(
            height: 76,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              scrollDirection: Axis.horizontal,
              itemCount: _gameModes.length,
              itemBuilder: (context, index) {
                return _buildGameCard(index);
              },
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // Card cho từng game mode
  Widget _buildGameCard(int index) {
    final game = _gameModes[index];
    final isSelected = _selectedGame == index;

    return GestureDetector(
      onTap: () {
        if (_selectedGame != index) {
          setState(() => _selectedGame = index);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 12),
        width: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? game.gradient
                : [const Color(0xFF1E2030), const Color(0xFF1A1A2E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? game.accentColor.withValues(alpha: 0.8)
                : const Color(0xFF2E3050),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: game.accentColor.withValues(alpha: 0.25),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              // Icon container
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isSelected
                      ? game.accentColor.withValues(alpha: 0.2)
                      : const Color(0xFF252840),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? game.accentColor.withValues(alpha: 0.5)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  game.icon,
                  color: isSelected
                      ? game.accentColor
                      : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      game.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFFF5F5F5)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      game.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: isSelected
                            ? const Color(0xFFA0A0B0)
                            : const Color(0xFF4B5265),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
