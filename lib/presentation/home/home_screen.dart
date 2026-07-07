import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'widgets/bottom_nav_bar.dart';
import '../matches/matches_screen.dart';
import '../history/history_screen.dart';
import '../profile/profile_screen.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/enums/auth_status.dart';
import '../../core/router/app_routes.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);
    final isGuest = authStatus == AuthStatus.unauthenticated;
    final currentUser = ref.watch(currentUserProvider);

    // Safely listen to auth status changes to reset selected index on sign out
    ref.listen<AuthStatus>(authStatusProvider, (previous, next) {
      if (next == AuthStatus.unauthenticated && _selectedIndex > 1) {
        setState(() {
          _selectedIndex = 0;
        });
      }
    });

    // Compute displayIndex locally to avoid mutating state during build
    final displayIndex = (isGuest && _selectedIndex > 1) ? 0 : _selectedIndex;

    final List<Widget> screens = [
      _buildHomeContent(isGuest, currentUser),
      const MatchesScreen(),
      if (!isGuest) ...[
        const HistoryScreen(),
        ProfileScreen(onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        }),
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
                  Icon(Icons.home_work_outlined, color: Color(0xFFE94560)),
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
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFF5F5F5),
                          backgroundColor: const Color(0xFFE94560),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.login, size: 16),
                        label: const Text(
                          'Đăng nhập',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () => context.push(AppRoutes.login),
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

  Widget _buildHomeContent(bool isGuest, dynamic currentUser) {
    if (isGuest) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
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
                  border: Border.all(color: const Color(0xFF0F3460)),
                ),
                padding: const EdgeInsets.all(20.0),
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
        padding: const EdgeInsets.all(24.0),
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
                border: Border.all(color: const Color(0xFF0F3460)),
              ),
              padding: const EdgeInsets.all(20.0),
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
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('wallets')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data!.exists) {
                        final data = snapshot.data!.data() as Map<String, dynamic>?;
                        final balance = data?['balance'] ?? 0;
                        final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
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
