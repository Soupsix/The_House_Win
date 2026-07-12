import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../application/wallet/wallet_provider.dart';
import '../../application/anti_gambling/anti_gambling_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../core/router/app_routes.dart';
import '../../domain/enums/auth_status.dart';
import '../anti_gambling/loan_trap_screen.dart';
import '../wallet/wallet_screen.dart';
import '../arenas/arenas_screen.dart';
import '../profile/profile_screen.dart';
import '../betting/my_bets_screen.dart';
import 'widgets/bottom_nav_bar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final user = ref.read(currentUserProvider);

      if (user != null) {
        ref.read(walletProvider.notifier).watchWallet(user.uid);
        ref.read(walletProvider.notifier).loadWallet(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);
    final isGuest = authStatus == AuthStatus.unauthenticated;
    final currentUser = ref.watch(currentUserProvider);
    final showLoanTrap = ref.watch(showLoanTrapProvider);

    ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
      if (next == AuthStatus.unauthenticated && _selectedIndex > 1) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });

    final displayIndex =
    (isGuest && _selectedIndex > 1) ? 0 : _selectedIndex;

    final List<Widget> screens = [
      _buildHomeContent(
        context,
        isGuest,
        currentUser,
        showLoanTrap,
      ),
      const ArenasScreen(),
      if (!isGuest) ...[
        const MyBetsScreen(),
        const WalletScreen(),
        ProfileScreen(
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
      ],
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: displayIndex == 0
          ? AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.home_work_outlined,
              color: Color(0xFFE94560),
            ),
            SizedBox(width: 8),
            Text(
              'The House Wins',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F5F5),
              ),
            ),
          ],
        ),
        actions: [
          if (isGuest)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFF5F5F5),
                    backgroundColor: const Color(0xFFE94560),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(
                    Icons.login,
                    size: 16,
                  ),
                  label: const Text(
                    'Đăng nhập',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  onPressed: () => context.go(AppRoutes.login),
                ),
              ),
            ),
        ],
      )
          : null,
      body: IndexedStack(
        index: displayIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: displayIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    bool isGuest,
    dynamic currentUser,
    bool showLoanTrap,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header / VIP Wallet Card
          _AnimatedFadeInUp(
            delay: 100,
            child: isGuest
                ? _buildGuestCard(context)
                : _buildUserWalletCard(context, currentUser),
          ),

          if (!isGuest && showLoanTrap) ...[
            const SizedBox(height: 16),
            _AnimatedFadeInUp(
              delay: 200,
              child: _buildLoanTrapBanner(context),
            ),
          ],

          const SizedBox(height: 32),

          // 2. Featured Arenas
          _AnimatedFadeInUp(
            delay: 300,
            child: _buildFeaturedArenas(context, isGuest),
          ),

          const SizedBox(height: 32),

          // 3. Recent Activity (Placeholder/Live feed)
          if (!isGuest)
            _AnimatedFadeInUp(
              delay: 400,
              child: _buildRecentActivity(),
            ),
        ],
      ),
    );
  }

  Widget _buildGuestCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A1B38), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE94560).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE94560).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.stars_rounded, size: 64, color: Color(0xFFFFB347)),
          const SizedBox(height: 16),
          const Text(
            'CHÀO MỪNG ĐẾN VỚI\nTHE HOUSE WINS',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Đăng nhập ngay để nhận 1.000.000 VNĐ ảo\nvà bắt đầu hành trình của bạn.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Be Vietnam Pro',
              fontSize: 14,
              color: Color(0xFFA0A0B0),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
              shadowColor: const Color(0xFFE94560).withValues(alpha: 0.5),
            ),
            onPressed: () => context.go(AppRoutes.login),
            child: const Text(
              'ĐĂNG NHẬP NGAY',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                fontSize: 15,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserWalletCard(BuildContext context, dynamic currentUser) {
    final name = currentUser?.displayName ?? 'Player';
    final uid = currentUser?.uid ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Stack(
        children: [
          // Background Card with Glassmorphism
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4AA).withValues(alpha: 0.15),
                      const Color(0xFF16213E).withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF00D4AA).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4AA).withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: const Color(0xFF00D4AA).withValues(alpha: 0.2),
                              child: const Icon(Icons.person, color: Color(0xFF00D4AA)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'THÀNH VIÊN',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF00D4AA),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB347).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFB347).withValues(alpha: 0.5)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.workspace_premium, size: 14, color: Color(0xFFFFB347)),
                              SizedBox(width: 4),
                              Text(
                                'VIP',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFB347),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SỐ DƯ KHẢ DỤNG',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 12,
                        color: Color(0xFFA0A0B0),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance.collection('wallets').doc(uid).snapshots(),
                      builder: (context, snapshot) {
                        double balance = 0;
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final data = snapshot.data!.data();
                          final total = (data?['balance'] as num?)?.toDouble() ?? 0;
                          final locked = (data?['lockedAmount'] as num?)?.toDouble() ?? 0;
                          balance = total - locked;
                        }

                        return TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: balance),
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeOutQuart,
                          builder: (context, value, child) {
                            final formatter = NumberFormat.currency(
                              locale: 'vi_VN',
                              symbol: 'VNĐ',
                              decimalDigits: 0,
                            );
                            return Text(
                              formatter.format(value),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color(0xFF00D4AA),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF444455)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 2; // My Bets
                              });
                            },
                            icon: const Icon(Icons.history, size: 18),
                            label: const Text('Lịch sử cược', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D4AA),
                              foregroundColor: const Color(0xFF1A1A2E),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF00D4AA),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedIndex = 3; // Wallet
                              });
                            },
                            icon: const Icon(Icons.account_balance_wallet, size: 18),
                            label: const Text('Chi tiết ví', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanTrapBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LoanTrapScreen())),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFFC536D).withValues(alpha: 0.2),
                    const Color(0xFF3A1625),
                  ],
                ),
                border: Border.all(color: const Color(0xFFFC536D), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFC536D).withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFC536D)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SỐ DƯ QUÁ THẤP!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFC536D),
                            letterSpacing: 1.0,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Nhận ngay gói cứu trợ mô phỏng để gỡ gạc.',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFFC536D)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedArenas(BuildContext context, bool isGuest) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SẢNH CƯỢC HOT',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            children: [
              _buildArenaCard(
                title: 'Tài Xỉu Siêu Tốc',
                subtitle: 'Kết quả mỗi 1 phút',
                icon: Icons.casino,
                color: const Color(0xFFFC536D),
                onTap: () {
                  if (isGuest) {
                    context.go(AppRoutes.login);
                  } else {
                    setState(() => _selectedIndex = 1);
                  }
                },
              ),
              const SizedBox(width: 16),
              _buildArenaCard(
                title: 'Bóng Đá Ảo',
                subtitle: 'Mô phỏng trận đấu',
                icon: Icons.sports_soccer,
                color: const Color(0xFF00D4AA),
                onTap: () {
                  if (isGuest) {
                    context.go(AppRoutes.login);
                  } else {
                    setState(() => _selectedIndex = 1);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArenaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF222233),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  icon,
                  size: 100,
                  color: color.withValues(alpha: 0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 11,
                        color: Color(0xFFA0A0B0),
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

  Widget _buildRecentActivity() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HOẠT ĐỘNG GẦN ĐÂY',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF222233),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF333344)),
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.query_stats_rounded, size: 48, color: Color(0xFF555566)),
                  SizedBox(height: 12),
                  Text(
                    'Bàn cược đang chờ bạn',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tham gia sảnh cược để hiển thị lịch sử tại đây.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 12,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget Animation hỗ trợ Fade In Up
class _AnimatedFadeInUp extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedFadeInUp({required this.child, this.delay = 0});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}