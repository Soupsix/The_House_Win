import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/wallet/wallet_provider.dart';
import '../../application/wallet/wallet_state.dart';
import '../../application/auth/auth_provider.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _withdrawController = TextEditingController();

  late Timer _shuffleTimer;
  final Random _random = Random();
  late List<int> _withdrawAmounts;
  late List<String> _withdrawNames;

  final List<String> _baseNames = [
    'Nguyễn Văn Tuấn', 'Trần Thị Mai', 'Lê Hoàng Sơn', 'Phạm Quỳnh Anh',
    'Hoàng Minh Nhật', 'Vũ Thu Thảo', 'Đặng Hải Đăng', 'Bùi Ngọc Linh',
    'Đỗ Văn Quyết', 'Hồ Thanh Tùng', 'Ngô Bảo Châu', 'Dương Tấn Phát',
    'Lý Hương Giang', 'Đào Quốc Việt', 'Đoàn Thanh Trúc', 'Vương Đình Huệ',
    'Trịnh Thị Nụ', 'Đinh Công Tráng', 'Lâm Chấn Huy', 'Phùng Thanh Độ',
    'Mai Khôi', 'Tô Hữu Bằng', 'Nguyễn Thái Học', 'Trần Hưng Đạo',
    'Lê Ngọc Hân', 'Phan Bội Châu', 'Hoàng Hoa Thám', 'Bùi Anh Tuấn',
    'Vũ Đức Đam', 'Trần Thu Hà', 'Lê Bích Phương', 'Đặng Thùy Trâm'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Generate 22 random amounts between 10m and 100m (step 100k)
    _withdrawAmounts = List.generate(
      22, 
      (_) => 10000000 + _random.nextInt(900) * 100000
    )..sort((a, b) => b.compareTo(a));

    // Get 22 random names
    final shuffledNames = List<String>.from(_baseNames)..shuffle(_random);
    _withdrawNames = shuffledNames.take(22).toList();

    _shuffleTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _withdrawNames.shuffle(_random);
        });
      }
    });

    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(walletProvider.notifier).loadWallet(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _shuffleTimer.cancel();
    _tabController.dispose();
    _withdrawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);
    final user = ref.watch(currentUserProvider);
    final vnd = NumberFormat('#,###', 'vi_VN');

    if (user == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D0D1A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, color: Color(0xFFE94560), size: 64),
              SizedBox(height: 16),
              Text('Đăng nhập để xem ví của bạn',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      body: walletState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE94560)))
          : RefreshIndicator(
              color: const Color(0xFFE94560),
              backgroundColor: const Color(0xFF16213E),
              onRefresh: () async =>
                  ref.read(walletProvider.notifier).loadWallet(user.uid),
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Column(
                            children: [
                              _buildWalletCard(walletState, vnd),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                                child: _buildStatsRow(walletState, vnd),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFFE94560),
                          labelColor: const Color(0xFFE94560),
                          unselectedLabelColor: const Color(0xFF6A7A9A),
                          indicatorWeight: 3,
                          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          unselectedLabelStyle: const TextStyle(fontSize: 13),
                          tabs: const [
                            Tab(text: 'NGƯỜI THÀNH CÔNG'),
                            Tab(text: 'RÚT TIỀN'),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSuccessfulWithdrawers(vnd),
                    _buildWithdrawTab(walletState, user.uid, vnd),
                  ],
                ),
              ),
            ),
    );
  }

  // ── Wallet Card (Virtual Card) ──
  Widget _buildWalletCard(WalletState w, NumberFormat vnd) {
    final isBroke = w.balance < 50000;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isBroke
              ? [const Color(0xFF5A0A0A), const Color(0xFF2A0A1A)]
              : [const Color(0xFF1A4A8A), const Color(0xFF0F3460)],
        ),
        boxShadow: [
          BoxShadow(
            color: (isBroke ? const Color(0xFFE94560) : const Color(0xFF1A4A8A))
                .withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('THE HOUSE WINS',
                      style: TextStyle(
                          color: Colors.white54,
                          letterSpacing: 2,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Crypto Wallet',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 10)),
                ],
              ),
              if (isBroke)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE94560).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: const Color(0xFFE94560), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Color(0xFFE94560), size: 14),
                      SizedBox(width: 4),
                      Text('CHÁY TÚI',
                          style: TextStyle(
                              color: Color(0xFFE94560),
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else
                const Icon(Icons.contactless, color: Colors.white54, size: 28),
            ],
          ),
          const SizedBox(height: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('SỐ DƯ HIỆN TẠI',
                  style: TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 4),
              Text(
                '${vnd.format(w.balance)} VNĐ',
                style: TextStyle(
                    color: isBroke
                        ? const Color(0xFFE94560)
                        : Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCardStat('KHẢ DỤNG', '${vnd.format(w.availableBalance)} đ',
                  const Color(0xFF28DFB5)),
              _buildCardStat('ĐANG KHÓA', '${vnd.format(w.lockedAmount)} đ',
                  const Color(0xFFFFB347)),
              _buildCardStat('TỔNG THẮNG',
                  '${vnd.format(w.totalWon)} đ', const Color(0xFF8B5CF6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardStat(String label, String value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 9)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      );

  // ── Stats Row ──
  Widget _buildStatsRow(WalletState w, NumberFormat vnd) {
    return Row(
      children: [
        Expanded(
            child: _buildStatCard(
                'Tổng đặt',
                vnd.format(w.totalBet),
                Icons.sports_soccer,
                const Color(0xFFFFB347))),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard(
                'Thắng',
                vnd.format(w.totalWon),
                Icons.emoji_events,
                const Color(0xFF28DFB5))),
        const SizedBox(width: 8),
        Expanded(
            child: _buildStatCard(
                'GD',
                '${w.transactionHistory.length}',
                Icons.receipt_long,
                const Color(0xFF8B5CF6))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label,
              style: const TextStyle(color: Color(0xFF6A7A9A), fontSize: 10)),
        ],
      ),
    );
  }

  // ── Successful Withdrawers Tab ──
  Widget _buildSuccessfulWithdrawers(NumberFormat vnd) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: 22,
      itemBuilder: (context, index) {
        final amount = _withdrawAmounts[index];
        final name = _withdrawNames[index];
        final isTop3 = index < 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: isTop3 
                    ? const Color(0xFFFFB347).withValues(alpha: 0.5) 
                    : const Color(0xFF28DFB5).withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isTop3 
                      ? const Color(0xFFFFB347).withValues(alpha: 0.15) 
                      : const Color(0xFF28DFB5).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: isTop3
                    ? const Icon(Icons.emoji_events, color: Color(0xFFFFB347), size: 22)
                    : Text(
                        '#${index + 1}',
                        style: const TextStyle(
                            color: Color(0xFF28DFB5),
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    const Text('Rút tiền thành công',
                        style: TextStyle(
                            color: Color(0xFF6A7A9A), fontSize: 11)),
                  ],
                ),
              ),
              Text(
                '+${vnd.format(amount)} đ',
                style: const TextStyle(
                  color: Color(0xFF28DFB5),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Withdraw Tab ──
  Widget _buildWithdrawTab(WalletState w, String uid, NumberFormat vnd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Withdraw threshold warning
          if (w.balance < 50000)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE94560).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFE94560).withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE94560), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Số dư dưới ngưỡng tối thiểu 50,000 VNĐ. Tài khoản bị coi là cháy túi.',
                      style: TextStyle(color: Color(0xFFE94560), fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          const Text('YÊU CẦU RÚT TIỀN',
              style: TextStyle(
                  color: Color(0xFF6A7A9A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1A3060)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Số dư khả dụng:',
                        style: TextStyle(color: Color(0xFF6A7A9A))),
                    Text('${vnd.format(w.availableBalance)} VNĐ',
                        style: const TextStyle(
                            color: Color(0xFF28DFB5),
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _withdrawController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF0D0D1A),
                    hintText: '0',
                    hintStyle: const TextStyle(color: Colors.white24),
                    suffixText: 'VNĐ',
                    suffixStyle: const TextStyle(color: Color(0xFF6A7A9A)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A3060)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF1A3060)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE94560)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Quick buttons
                Row(
                  children: ['100,000', '200,000', '500,000'].map((amt) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(
                            () => _withdrawController.text = amt.replaceAll(',', '')),
                        child: Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F1D33),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF1A3060)),
                          ),
                          child: Text(amt,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF00D4AA),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE94560),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: w.isLoading
                        ? null
                        : () async {
                            final amount = double.tryParse(
                                    _withdrawController.text.replaceAll(',', '')) ??
                                0;
                            if (amount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Nhập số tiền cần rút')),
                              );
                              return;
                            }
                            await ref
                                .read(walletProvider.notifier)
                                .requestWithdrawal(uid, amount);
                            _withdrawController.clear();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã gửi yêu cầu rút tiền!'),
                                backgroundColor: Color(0xFF28DFB5),
                              ),
                            );
                          },
                    child: const Text('GỬI YÊU CẦU RÚT TIỀN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('THÔNG TIN VÍ',
              style: TextStyle(
                  color: Color(0xFF6A7A9A),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5)),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.account_balance_wallet, 'Tổng số dư',
              '${vnd.format(w.balance)} VNĐ', const Color(0xFF28DFB5)),
          _buildInfoRow(Icons.lock, 'Tiền đang khóa (Escrow)',
              '${vnd.format(w.lockedAmount)} VNĐ', const Color(0xFFFFB347)),
          _buildInfoRow(Icons.check_circle, 'Tiền khả dụng',
              '${vnd.format(w.availableBalance)} VNĐ',
              const Color(0xFF00D4AA)),
          _buildInfoRow(Icons.trending_up, 'Tổng thắng',
              '${vnd.format(w.totalWon)} VNĐ', const Color(0xFF8B5CF6)),
          _buildInfoRow(Icons.trending_down, 'Tổng thua',
              '${vnd.format(w.totalLost)} VNĐ', const Color(0xFFE94560)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 13))),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0D0D1A),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: _tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
