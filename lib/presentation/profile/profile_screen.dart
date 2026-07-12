import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../application/auth/auth_provider.dart';
import '../../core/router/app_routes.dart';
import '../betting/my_bets_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final VoidCallback? onBackToHome;

  const ProfileScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: Text(
            'Vui lòng đăng nhập',
            style: TextStyle(color: Color(0xFFF5F5F5)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFE94560)),
          onPressed: onBackToHome,
        ),
        title: const Text(
          'Hồ sơ',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Color(0xFFE94560),
          ),
        ),
        
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar & Name Section
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE94560).withOpacity(0.5),
                            width: 2.5,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const CircleAvatar(
                          backgroundImage: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuAaXGb4BVTDz0nDU3PnCIm7f07yiBBib4SWRNDVq85w9CHFfDzqA7p1LtjPnsvIUJucFOsBVIiCPA3NwMRsnyJ1IJplOXtc7c51ZDTapTP8EU6-LuahqtCCYZzAmJP2wMur3DCD5A_d5CEiqbMVzjRzcIevsQWHyEF-pC9EqOUWeIAYqrR8_7Bq3yZwYf4BBXZ4uSF4N69-K2C0fra-1UjR95ET8ZH1-mB4YFXUazFQ-eWcmnEQu1ygcXSshWrgbwg6pGEXFoO0Tb3p',
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE94560),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFFF5F5F5),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser.displayName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF5F5F5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF0F3460)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, color: Color(0xFFFFB347), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Thành viên Bạc',
                          style: TextStyle(
                            fontFamily: 'Be Vietnam Pro',
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
            ),
            const SizedBox(height: 32),

            // Wallet Summary Card (Glassmorphic look)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F3460)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Số dư hiện tại',
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
                        .doc(currentUser.uid)
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
                            color: Color(0xFFF5F5F5),
                          ),
                        );
                      }
                      return const Text(
                        '0 VNĐ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3460),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      icon: const Icon(Icons.add_circle, color: Color(0xFF00D4AA)),
                      label: const Text(
                        'Nạp tiền',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF5F5F5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Menu List
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F3460)),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    Icons.person,
                    'Thông tin cá nhân',
                    onTap: () => context.push(AppRoutes.personalInfo),
                  ),
                  const Divider(color: Color(0xFF0F3460), height: 1, indent: 16, endIndent: 16),
                  _buildMenuItem(
                    Icons.history, 
                    'Lịch sử cược',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyBetsScreen()),
                    ),
                  ),
                  const Divider(color: Color(0xFF0F3460), height: 1, indent: 16, endIndent: 16),
                  _buildMenuItem(Icons.account_balance_wallet, 'Ví điện tử'),
                  const Divider(color: Color(0xFF0F3460), height: 1, indent: 16, endIndent: 16),
                  _buildMenuItem(Icons.security, 'Bảo mật'),
                  const Divider(color: Color(0xFF0F3460), height: 1, indent: 16, endIndent: 16),
                  _buildMenuItem(Icons.support_agent, 'Hỗ trợ & CSKH'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3A1A1A),
                  side: BorderSide(color: const Color(0xFFE94560).withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                icon: const Icon(Icons.logout, color: Color(0xFFE94560)),
                label: const Text(
                  'Đăng xuất',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE94560),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Version info
            const Text(
              'Phiên bản 2.4.0 • Cyber-Fidelity',
              style: TextStyle(
                fontFamily: 'Be Vietnam Pro',
                fontSize: 12,
                color: Color(0xFFA0A0B0),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFE94560), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Be Vietnam Pro',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFA0A0B0), size: 18),
          ],
        ),
      ),
    );
  }
}
