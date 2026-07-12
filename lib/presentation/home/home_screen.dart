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
import '../matches/matches_screen.dart';
import '../leagues/leagues_screen.dart';
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

    // Guest chỉ thấy Home (0), Sàn đấu (1), Giải đấu (2)
    // Logged-in có thêm Ví (3) và Hồ sơ (4)
    final displayIndex =
        (isGuest && _selectedIndex > 2) ? 0 : _selectedIndex;

    final List<Widget> screens = [
      _buildHomeContent(
        context,
        isGuest,
        currentUser,
        showLoanTrap,
      ),
      const MatchesScreen(), // index 1
      const LeaguesScreen(), // index 2 - Giải đấu (available to all users)
      if (!isGuest) ...[
        const WalletScreen(), // index 3
        ProfileScreen(        // index 4
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
    if (isGuest) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.home_work_outlined,
                size: 80,
                color: Color(0xFFE94560),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chào mừng, Khách!',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF16213E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF0F3460),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    Text(
                      'Ví ảo của bạn',
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 13,
                        color: Color(0xFFA0A0B0),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '0 VNĐ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB347),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng nhập để nhận ngay 1.000.000 VNĐ ảo và tham gia mô phỏng cá cược không rủi ro!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 14,
                  color: Color(0xFFA0A0B0),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final name = currentUser?.displayName ?? '';
    final uid = currentUser?.uid ?? '';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Color(0xFFE94560),
            ),
            const SizedBox(height: 16),
            Text(
              'Chào mừng, $name!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F5F5),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF0F3460),
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Số dư ví ảo',
                    style: TextStyle(
                      fontFamily: 'Be Vietnam Pro',
                      fontSize: 13,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 6),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('wallets')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data();
                        final balance =
                            (data?['balance'] as num?)?.toDouble() ?? 0;

                        final formatter = NumberFormat.currency(
                          locale: 'vi_VN',
                          symbol: 'VNĐ',
                          decimalDigits: 0,
                        );

                        return Text(
                          formatter.format(balance),
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00D4AA),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Text(
                          'Không thể tải số dư',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE94560),
                          ),
                        );
                      }

                      return const Text(
                        '0 VNĐ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D4AA),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (showLoanTrap) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A1625),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE94560),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 40,
                      color: Color(0xFFE94560),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Số dư của bạn đang ở mức rất thấp',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF5F5F5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bạn có muốn sử dụng gói vay vốn mô phỏng để tiếp tục chơi không?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Be Vietnam Pro',
                        fontSize: 14,
                        color: Color(0xFFA0A0B0),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          Icons.account_balance_wallet_outlined,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE94560),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        label: const Text(
                          'VAY THÊM TIỀN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LoanTrapScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Chúc bạn trải nghiệm vui vẻ! Học cách không thua để luôn thắng.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 14,
                color: Color(0xFFA0A0B0),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}