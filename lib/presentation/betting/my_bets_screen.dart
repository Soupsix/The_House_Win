import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/bets/bet_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/enums/bet_status.dart';
import '../../domain/enums/bet_choice.dart';

// Màn hình lịch sử đặt cược của tôi (gồm cược đang chạy và cược đã kết toán)
class MyBetsScreen extends ConsumerStatefulWidget {
  const MyBetsScreen({super.key});

  @override
  ConsumerState<MyBetsScreen> createState() => _MyBetsScreenState();
}

class _MyBetsScreenState extends ConsumerState<MyBetsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Tự động tải lịch sử đơn cược khi mở màn hình
    Future.microtask(() {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(betProvider.notifier).loadBets(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Format tiền tệ dạng "50.000 đ"
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

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2020),
        elevation: 0,
        title: const Text(
          'ĐƠN CƯỢC CỦA TÔI',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFC536D),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFA0A0B0),
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          tabs: const [
            Tab(text: 'PHIÊN HIỆN TẠI'),
            Tab(text: 'LỊCH SỬ CƯỢC'),
          ],
        ),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'Vui lòng đăng nhập để xem đơn cược',
                style: TextStyle(fontFamily: 'Inter', color: Color(0xFFA0A0B0)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildActiveTab(user.uid),
                _buildHistoryTab(user.uid),
              ],
            ),
    );
  }

  // Tab cược phiên đang chạy
  Widget _buildActiveTab(String uid) {
    final activeBets = ref.watch(currentSessionBetsProvider);

    if (activeBets.isEmpty) {
      return _buildEmptyState('Không có đơn cược pending trong phiên này');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeBets.length,
      itemBuilder: (context, index) {
        final bet = activeBets[index];
        return _buildBetCard(bet);
      },
    );
  }

  // Tab lịch sử cược
  Widget _buildHistoryTab(String uid) {
    final settledBets = ref.watch(settledBetsProvider);
    final isLoading = ref.watch(betProvider.select((s) => s.isLoading));

    if (settledBets.isEmpty) {
      if (isLoading) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFFC536D)),
        );
      }
      return _buildEmptyState('Lịch sử đặt cược trống');
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(betProvider.notifier).loadBets(uid),
      color: const Color(0xFFFC536D),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: settledBets.length + 1,
        itemBuilder: (context, index) {
          if (index == settledBets.length) {
            // Nút load more ở cuối list
            return Container(
              margin: const EdgeInsets.only(top: 8, bottom: 24),
              child: Center(
                child: TextButton(
                  onPressed: () => ref.read(betProvider.notifier).loadMoreHistory(uid),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFFC536D),
                          ),
                        )
                      : const Text(
                          'TẢI THÊM LỊCH SỬ',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFFC536D),
                            letterSpacing: 1.2,
                          ),
                        ),
                ),
              ),
            );
          }
          return _buildBetCard(settledBets[index]);
        },
      ),
    );
  }

  // Render một card cược
  Widget _buildBetCard(BetModel bet) {
    final isChoiceOver = bet.choice == BetChoice.over;
    final isPending = bet.status == BetStatus.pending;
    final isWon = bet.status == BetStatus.won;
    final isPush = bet.status == BetStatus.push;

    Color statusColor;
    String statusText;

    if (isPending) {
      statusColor = const Color(0xFFFFB347);
      statusText = 'PENDING';
    } else if (isWon) {
      statusColor = const Color(0xFF00D4AA);
      statusText = 'THẮNG';
    } else if (isPush) {
      statusColor = const Color(0xFFA0A0B0);
      statusText = 'HOÀN TIỀN';
    } else {
      statusColor = const Color(0xFFFC536D);
      statusText = 'THUA';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF333535)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                bet.sessionNumber != null ? 'Phiên #${bet.sessionNumber}' : 'Cược Bóng Đá',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Body Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LỰA CHỌN',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isChoiceOver ? '🔴 TÀI' : '🟢 XỈU',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isChoiceOver ? const Color(0xFFFC536D) : const Color(0xFF00D4AA),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'MỨC CƯỢC',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatBalance(bet.amount),
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    isPending ? 'TRẢ THƯỞNG DỰ KIẾN' : 'TRẢ THƯỞNG',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isPending
                        ? _formatBalance(bet.amount * bet.oddsAtTime)
                        : _formatBalance(bet.payout),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isPending
                          ? const Color(0xFFFFB347)
                          : (isWon ? const Color(0xFF00D4AA) : const Color(0xFFA0A0B0)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 48,
            color: Color(0xFF333535),
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: Color(0xFFA0A0B0),
            ),
          ),
        ],
      ),
    );
  }
}
