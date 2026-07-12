import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/admin/admin_provider.dart';
import '../../application/admin/admin_state.dart';
import '../../application/admin/admin_notifier.dart';
import '../../application/matches/match_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../domain/models/match_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/enums/match_status.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTab = 0; // 0: Dashboard, 1: Players, 2: Matches, 3: Logs
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load matches from Firestore when admin panel opens
    Future.microtask(() async {
      await ref.read(matchProvider.notifier).loadFromCache();
      // Auto-sync real matches from API to Firebase on load
      ref.read(matchProvider.notifier).adminSyncApiToFirestore();
    });
  }

  // Dialog configurations
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _oddsOverController = TextEditingController();
  final TextEditingController _oddsUnderController = TextEditingController();
  final TextEditingController _lineController = TextEditingController();

  // Create simulated match controllers
  final TextEditingController _homeController = TextEditingController();
  final TextEditingController _awayController = TextEditingController();
  Future<void> _confirmApproveWithdrawal({
    required AdminNotifier adminNotifier,
    required String requestId,
    required String userId,
    required String displayName,
    required double amount,
    required double currentBalance,
  }) async {
    final hasEnoughBalance = currentBalance >= amount;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2020),
          title: const Text(
            'Xác nhận duyệt rút tiền',
            style: TextStyle(
              color: Color(0xFFE2E2E2),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Người chơi: $displayName',
                style: const TextStyle(
                  color: Color(0xFFE2E2E2),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Số dư hiện tại: ${_formatCurrency(currentBalance)}',
                style: const TextStyle(
                  color: Color(0xFF28DFB5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Số tiền yêu cầu: ${_formatCurrency(amount)}',
                style: const TextStyle(
                  color: Color(0xFFFFB2B7),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                hasEnoughBalance
                    ? 'Sau khi duyệt, số tiền này sẽ được trừ khỏi ví người chơi.'
                    : 'Ví người chơi không đủ số dư để duyệt yêu cầu này.',
                style: TextStyle(
                  color: hasEnoughBalance
                      ? const Color(0xFFE2BEBF)
                      : const Color(0xFFFC536D),
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: hasEnoughBalance
                  ? () {
                      Navigator.pop(dialogContext, true);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28DFB5),
                foregroundColor: Colors.black,
              ),
              child: const Text('Duyệt rút tiền'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await adminNotifier.approveWithdrawal(
      requestId,
      userId,
      amount,
    );
  }

  Future<void> _confirmRejectWithdrawal({
    required AdminNotifier adminNotifier,
    required String requestId,
    required String displayName,
    required double amount,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2020),
          title: const Text(
            'Từ chối yêu cầu rút tiền?',
            style: TextStyle(
              color: Color(0xFFE2E2E2),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Bạn có chắc muốn từ chối yêu cầu rút '
            '${_formatCurrency(amount)} của $displayName không?',
            style: const TextStyle(
              color: Color(0xFFE2BEBF),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC536D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Từ chối'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await adminNotifier.rejectWithdrawal(requestId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    _oddsOverController.dispose();
    _oddsUnderController.dispose();
    _lineController.dispose();
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  // Helper to format currency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'SC');
    return formatter.format(amount).replaceAll('VNĐ', 'SC');
  }

  // Visual helper: Glass Card
  Widget _buildGlassCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? color,
  }) {
    return Container(
      width: width,
      height: height,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? const Color(0xFF1E2020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA9898A).withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final adminNotifier = ref.read(adminProvider.notifier);
    final liveMatches = ref.watch(liveMatchesProvider);
    final scheduledMatches = ref.watch(scheduledMatchesProvider);

    // Show error/success SnackBars
    ref.listen<AdminState>(adminProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.errorMessage!),
              backgroundColor: const Color(0xFFFC536D)),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(next.successMessage!),
              backgroundColor: const Color(0xFF28DFB5)),
        );
      }
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF121414),
      body: SafeArea(
        child: isDesktop
            ? Row(
                children: [
                  // Sidebar navigation for Desktop
                  _buildSidebar(context),
                  const VerticalDivider(width: 1, color: Color(0xFF333535)),
                  // Content area
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDesktopHeader(context, adminState),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(24.0),
                            child: _buildSelectedTabContent(
                              adminState,
                              adminNotifier,
                              liveMatches,
                              scheduledMatches,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  // Mobile Header
                  _buildMobileHeader(context, adminState),
                  // Mobile Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSelectedTabContent(
                        adminState,
                        adminNotifier,
                        liveMatches,
                        scheduledMatches,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      bottomNavigationBar: isDesktop
          ? null
          : Container(
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: Color(0xFF333535), width: 1)),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentTab,
                backgroundColor: const Color(0xFF1E2020),
                selectedItemColor: const Color(0xFFFFB2B7),
                unselectedItemColor: const Color(0xFFE2BEBF).withOpacity(0.6),
                type: BottomNavigationBarType.fixed,
                onTap: (index) {
                  setState(() {
                    _currentTab = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Tổng quan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.group_outlined),
                    activeIcon: Icon(Icons.group),
                    label: 'Người chơi',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.sports_esports_outlined),
                    activeIcon: Icon(Icons.sports_esports),
                    label: 'Trận đấu',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.terminal_outlined),
                    activeIcon: Icon(Icons.terminal),
                    label: 'Nhật ký',
                  ),
                ],
              ),
            ),
    );
  }

  // --- Header & Navigation Widgets ---

  Widget _buildSidebar(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    return Container(
      width: 260,
      color: const Color(0xFF1E2020),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFFFB2B7), size: 28),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SimBet Admin',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: Color(0xFFE2E2E2),
                    ),
                  ),
                  Text(
                    'V2.4.0 Stable',
                    style: TextStyle(
                      fontFamily: 'Public Sans',
                      fontSize: 11,
                      color: const Color(0xFFE2BEBF).withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                ),
                _buildSidebarItem(
                  icon: Icons.group,
                  label: 'Người chơi (Players)',
                  index: 1,
                ),
                _buildSidebarItem(
                  icon: Icons.sports_esports,
                  label: 'Active Matches',
                  index: 2,
                ),
                _buildSidebarItem(
                  icon: Icons.terminal,
                  label: 'System Logs',
                  index: 3,
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF333535)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFFB2B7).withOpacity(0.2),
              child: Text(
                (currentUser?.displayName.isNotEmpty ?? false)
                    ? currentUser!.displayName[0].toUpperCase()
                    : 'A',
                style: const TextStyle(
                    color: Color(0xFFFFB2B7), fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              currentUser?.displayName ?? 'Admin_Chief',
              style: const TextStyle(
                  color: Color(0xFFE2E2E2),
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: const Text(
              'Super Admin',
              style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 11),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93000a),
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Đăng xuất',
                style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              ref.read(authProvider.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
      {required IconData icon, required String label, required int index}) {
    final isSelected = _currentTab == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          selected: isSelected,
          selectedTileColor: const Color(0xFFFFB2B7).withOpacity(0.12),
          textColor: const Color(0xFFE2BEBF),
          selectedColor: const Color(0xFFFFB2B7),
          iconColor: const Color(0xFFE2BEBF),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon),
          title: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          onTap: () {
            setState(() {
              _currentTab = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDesktopHeader(BuildContext context, AdminState adminState) {
    return Container(
      height: 70,
      color: const Color(0xFF1E2020),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Search box linking to search state
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(adminProvider.notifier).setSearchQuery(val);
              },
              style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Tìm người chơi, email...',
                hintStyle:
                    TextStyle(color: const Color(0xFFE2BEBF).withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB2B7)),
                filled: true,
                fillColor: const Color(0xFF121414),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              ),
            ),
          ),
          const Row(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, color: Color(0xFFE2E2E2)),
                onPressed: null,
              ),
              IconButton(
                icon: Icon(Icons.settings_outlined, color: Color(0xFFE2E2E2)),
                onPressed: null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader(BuildContext context, AdminState adminState) {
    final currentUser = ref.watch(currentUserProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFF1E2020),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.lock, color: Color(0xFFFFB2B7), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Admin Panel',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFFE2E2E2),
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.logout, color: Color(0xFFFC536D)),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTab = 1; // Switch to player list
                  });
                },
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFFB2B7).withOpacity(0.2),
                  child: Text(
                    (currentUser?.displayName.isNotEmpty ?? false)
                        ? currentUser!.displayName[0].toUpperCase()
                        : 'A',
                    style: const TextStyle(
                        color: Color(0xFFFFB2B7),
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Dynamic Tab Switching ---

  Widget _buildSelectedTabContent(
    AdminState adminState,
    AdminNotifier adminNotifier,
    List<MatchModel> liveMatches,
    List<MatchModel> scheduledMatches,
  ) {
    if (adminState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: Color(0xFFFFB2B7)),
        ),
      );
    }

    switch (_currentTab) {
      case 0:
        return _buildDashboardTab(
            adminState, adminNotifier, liveMatches, scheduledMatches);
      case 1:
        return _buildPlayersTab(adminState, adminNotifier);
      case 2:
        return _buildMatchesTab(liveMatches, scheduledMatches);
      case 3:
        return _buildLogsTab(adminState);
      default:
        return _buildDashboardTab(
            adminState, adminNotifier, liveMatches, scheduledMatches);
    }
  }

  // ==========================================
  // VIEW: TAB 0 - DASHBOARD VIEW
  // ==========================================
  Widget _buildDashboardTab(
    AdminState adminState,
    AdminNotifier adminNotifier,
    List<MatchModel> liveMatches,
    List<MatchModel> scheduledMatches,
  ) {
    // Calculate total coins reserve in system
    double totalCoins = 0.0;
    adminState.userBalances.forEach((uid, balance) {
      totalCoins += balance;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bento Metrics Grid
        GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWide ? 1.4 : 1.3,
          children: [
            _buildMetricCard(
              title: 'Người dùng',
              value: adminState.users.length.toString(),
              icon: Icons.group,
              iconColor: const Color(0xFFFFB2B7),
              bgColor: const Color(0xFFFFB2B7).withOpacity(0.08),
            ),
            _buildMetricCard(
              title: 'Cược đang mở',
              value: (liveMatches.length + scheduledMatches.length).toString(),
              icon: Icons.receipt_long,
              iconColor: const Color(0xFFFFB95A),
              bgColor: const Color(0xFFFFB95A).withOpacity(0.08),
            ),
            _buildMetricCard(
              title: 'Tổng tiền ảo',
              value: totalCoins > 1000000
                  ? '${(totalCoins / 1000000).toStringAsFixed(1)}M'
                  : NumberFormat.compact().format(totalCoins),
              icon: Icons.account_balance_wallet,
              iconColor: const Color(0xFF28DFB5),
              bgColor: const Color(0xFF28DFB5).withOpacity(0.08),
            ),
            _buildMetricCard(
              title: 'Hệ thống',
              value: '99.98%',
              icon: Icons.query_stats,
              iconColor: const Color(0xFFFFB2B7),
              bgColor: const Color(0xFFFFB2B7).withOpacity(0.08),
              isSystemCard: true,
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Mobile search bar if mobile
        if (screenWidth <= 800) ...[
          TextField(
            controller: _searchController,
            onChanged: (val) {
              adminNotifier.setSearchQuery(val);
            },
            style: const TextStyle(color: Color(0xFFE2E2E2), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tìm người chơi...',
              hintStyle:
                  TextStyle(color: const Color(0xFFE2BEBF).withOpacity(0.5)),
              prefixIcon: const Icon(Icons.search, color: Color(0xFFFFB2B7)),
              filled: true,
              fillColor: const Color(0xFF1E2020),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Middle Section: Withdrawal Requests
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Yêu cầu rút tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E2E2),
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        'Duyệt hoặc từ chối các giao dịch tài chính.',
                        style:
                            const TextStyle(fontSize: 12, color: Color(0xFFE2BEBF)),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTab = 1;
                      });
                    },
                    child: const Text('Xem tất cả',
                        style: TextStyle(color: Color(0xFFFFB2B7))),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (adminState.withdrawalRequests.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Không có yêu cầu rút tiền nào đang chờ duyệt',
                      style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminState.withdrawalRequests.length,
                  separatorBuilder: (context, index) =>
                      const Divider(color: Color(0xFF333535), height: 16),
                  itemBuilder: (context, index) {
                    final req = adminState.withdrawalRequests[index];

                    final requestId = req['id']?.toString() ?? '';
                    final userId = req['userId']?.toString() ?? '';

                    final rawDisplayName =
                        req['displayName']?.toString().trim() ?? '';

                    final displayName =
                        rawDisplayName.isEmpty ? 'Người dùng' : rawDisplayName;

                    final amount = (req['amount'] as num?)?.toDouble() ?? 0.0;

                    final method =
                        req['method']?.toString() ?? 'Không xác định';

                    final currentBalance =
                        adminState.userBalances[userId] ?? 0.0;

                    final hasEnoughBalance = currentBalance >= amount;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFFB2B7).withValues(
                              alpha: 0.1,
                            ),
                            child: Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFFB2B7),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE2E2E2),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  method,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFE2BEBF),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Số dư: ${_formatCurrency(currentBalance)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: hasEnoughBalance
                                        ? const Color(0xFF28DFB5)
                                        : const Color(0xFFFC536D),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Yêu cầu: ${_formatCurrency(amount)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFB2B7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF28DFB5),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: hasEnoughBalance
                                    ? () {
                                        _confirmApproveWithdrawal(
                                          adminNotifier: adminNotifier,
                                          requestId: requestId,
                                          userId: userId,
                                          displayName: displayName,
                                          amount: amount,
                                          currentBalance: currentBalance,
                                        );
                                      }
                                    : null,
                                child: const Text(
                                  'Duyệt',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              TextButton(
                                onPressed: () {
                                  _confirmRejectWithdrawal(
                                    adminNotifier: adminNotifier,
                                    requestId: requestId,
                                    displayName: displayName,
                                    amount: amount,
                                  );
                                },
                                child: const Text(
                                  'Từ chối',
                                  style: TextStyle(
                                    color: Color(0xFFFC536D),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Live Matches Section
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF28DFB5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Trận đang mở',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E2E2),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTab = 2; // Switch to matches tab
                      });
                    },
                    child: const Text('Quản lý kèo',
                        style: TextStyle(color: Color(0xFFFFB2B7))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (liveMatches.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Text(
                      'Hiện tại không có trận đấu nào đang trực tiếp',
                      style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: liveMatches.length,
                  itemBuilder: (context, index) {
                    final match = liveMatches[index];
                    return _buildMatchAdminCard(match);
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Logs snippet
        _buildGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Nhật ký Admin',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E2E2),
                      fontFamily: 'Inter',
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentTab = 3; // Switch to logs tab
                      });
                    },
                    child: const Text('Xem nhật ký',
                        style: TextStyle(color: Color(0xFFFFB2B7))),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (adminState.adminLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Chưa có hoạt động nào được ghi nhận',
                      style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 13),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminState.adminLogs.length > 3
                      ? 3
                      : adminState.adminLogs.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final log = adminState.adminLogs[index];
                    final action = log['action'];
                    final timestamp = log['timestamp'] as DateTime;
                    final details = log['details'] as Map<String, dynamic>;

                    final dateStr = DateFormat('dd/MM HH:mm').format(timestamp);

                    String text = '';
                    if (action == 'OVERRIDE_MATCH_RESULT') {
                      text =
                          'Admin đã override trận đấu ${details['matchId']} sang kết quả ${details['result']}';
                    } else if (action == 'UPDATE_MATCH_ODDS') {
                      text =
                          'Admin đã sửa tỷ lệ cược trận ${details['matchId']}: Tài/Xỉu ${details['overUnderLine']}';
                    } else {
                      text = 'Hành động $action: ${details.toString()}';
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFB2B7),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFFFB2B7),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                text,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFFE2E2E2)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    bool isSystemCard = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2020),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFA9898A).withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              if (isSystemCard)
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF28DFB5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text('LIVE',
                        style: TextStyle(
                            color: Color(0xFF28DFB5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: const Color(0xFFE2BEBF).withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE2E2E2),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW: TAB 1 - DETAILED PLAYERS LIST VIEW
  // ==========================================
  Widget _buildPlayersTab(AdminState adminState, AdminNotifier adminNotifier) {
    final filteredUsers = adminState.filteredUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý người chơi',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE2E2E2),
                        fontFamily: 'Inter'),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Xem danh sách người chơi, số dư, số lần cháy túi và thực hiện thao tác khôi phục ví.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFE2BEBF)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];
            final balance = adminState.userBalances[user.uid] ?? 0.0;

            // Extra metrics safely from Firestore data
            // Since freezed creates raw fields, let's use manual logic if needed.
            // Currently UserModel has fields: uid, email, displayName, isAdmin, createdAt, phoneNumber.
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              const Color(0xFFFFB2B7).withOpacity(0.12),
                          child: Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                                color: Color(0xFFFFB2B7),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFE2E2E2)),
                                  ),
                                  const SizedBox(width: 8),
                                  if (user.isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFB95A)
                                            .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'ADMIN',
                                        style: TextStyle(
                                            color: Color(0xFFFFB95A),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.email,
                                style: TextStyle(
                                    color: const Color(0xFFE2BEBF)
                                        .withOpacity(0.7),
                                    fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'SĐT: ${user.phoneNumber.isNotEmpty ? user.phoneNumber : "N/A"}',
                                style: TextStyle(
                                    color: const Color(0xFFE2BEBF)
                                        .withOpacity(0.5),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'SỐ DƯ VÍ',
                              style: TextStyle(
                                  color: Color(0xFFE2BEBF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatCurrency(balance),
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF28DFB5)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF333535)),
                    const SizedBox(height: 8),
                    // Action Buttons for User
                    Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        // Reset wallet button
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF28DFB5),
                            side: const BorderSide(color: Color(0xFF28DFB5)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Reset về 0'),
                          onPressed: () => _showConfirmResetDialog(
                              context, adminNotifier, user),
                        ),
                        // Edit wallet balance button
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB2B7),
                            foregroundColor: const Color(0xFF67001C),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Chỉnh sửa tiền'),
                          onPressed: () => _showEditBalanceDialog(
                              context, adminNotifier, user, balance),
                        ),
                        if (!user.isAdmin)
                          // Toggle Admin privilege
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFFB95A),
                              side: const BorderSide(color: Color(0xFFFFB95A)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: const Icon(Icons.admin_panel_settings,
                                size: 16),
                            label: const Text('Cấp Admin'),
                            onPressed: () {
                              adminNotifier.toggleAdminStatus(user.uid, true);
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Confirm Reset Wallet Dialog
  void _showConfirmResetDialog(
      BuildContext context, AdminNotifier adminNotifier, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2020),
        title: const Text('Xác nhận khôi phục ví',
            style: TextStyle(color: Color(0xFFE2E2E2))),
        content: Text(
          'Bạn có chắc chắn muốn khôi phục số dư ví của ${user.displayName} về 1.000.000 SC mặc định và xóa toàn bộ lịch sử giao dịch?',
          style: const TextStyle(color: Color(0xFFE2BEBF)),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF28DFB5),
                foregroundColor: Colors.black),
            child: const Text('Khôi phục'),
            onPressed: () {
              adminNotifier.resetUserWallet(user.uid);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Edit Wallet Balance Dialog
  void _showEditBalanceDialog(BuildContext context, AdminNotifier adminNotifier,
      UserModel user, double currentBalance) {
    _amountController.text = currentBalance.toStringAsFixed(0);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2020),
        title: Text('Chỉnh sửa tiền ví ${user.displayName}',
            style: const TextStyle(color: Color(0xFFE2E2E2))),
        content: TextField(
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Số dư mới (SC)',
            labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF333535))),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFFFB2B7))),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB2B7),
                foregroundColor: const Color(0xFF67001C)),
            child: const Text('Lưu'),
            onPressed: () {
              final amt = double.tryParse(_amountController.text);
              if (amt != null && amt >= 0) {
                adminNotifier.adminEditBalance(user.uid, amt);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // VIEW: TAB 2 - MATCHES MANAGEMENT VIEW
  // ==========================================
  Widget _buildMatchesTab(
      List<MatchModel> liveMatches, List<MatchModel> scheduledMatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          runSpacing: 8.0,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quản lý kèo trận đấu',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE2E2E2),
                      fontFamily: 'Inter'),
                ),
                SizedBox(height: 4),
                Text(
                  'Điều chỉnh tỷ lệ cược hoặc cưỡng chế kết quả trận đấu giả lập.',
                  style: TextStyle(fontSize: 13, color: Color(0xFFE2BEBF)),
                ),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB2B7),
                foregroundColor: const Color(0xFF67001C),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tạo trận giả lập',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () => _showCreateMatchDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 24),

        if (liveMatches.isNotEmpty) ...[
          const Text(
            'Trận đấu đang diễn ra',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFB95A)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: liveMatches.length,
            itemBuilder: (context, index) {
              final match = liveMatches[index];
              return _buildMatchAdminCard(match);
            },
          ),
          const SizedBox(height: 24),
        ],
        if (scheduledMatches.isNotEmpty) ...[
          const Text(
            'Trận đấu sắp diễn ra',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E2E2)),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: scheduledMatches.length,
            itemBuilder: (context, index) {
              final match = scheduledMatches[index];
              return _buildMatchAdminCard(match);
            },
          ),
        ],
        if (liveMatches.isEmpty && scheduledMatches.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'Chưa có trận đấu nào. Hãy bấm "Tạo trận giả lập" để bắt đầu!',
                style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMatchAdminCard(MatchModel match) {
    final format = DateFormat('dd/MM HH:mm');
    final timeStr = format.format(match.utcDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: _buildGlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: match.status == MatchStatus.inPlay
                            ? const Color(0xFF28DFB5).withOpacity(0.12)
                            : const Color(0xFF333535),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        match.status == MatchStatus.inPlay ? 'LIVE' : 'SẮP ĐÁ',
                        style: TextStyle(
                          color: match.status == MatchStatus.inPlay
                              ? const Color(0xFF28DFB5)
                              : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (match.isSimulated)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB95A).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'GIẢ LẬP',
                          style: TextStyle(
                              color: Color(0xFFFFB95A),
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
                Text(
                  timeStr,
                  style:
                      const TextStyle(color: Color(0xFFE2BEBF), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    match.homeTeam,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121414),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${match.scoreHome} - ${match.scoreAway}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB2B7)),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.awayTeam,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('KÈO TÀI XỈU',
                        style:
                            TextStyle(color: Color(0xFFE2BEBF), fontSize: 10)),
                    const SizedBox(height: 4),
                    Text('${match.overUnderLine}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    const Text('TIỀN TÀI (OVER)',
                        style:
                            TextStyle(color: Color(0xFFE2BEBF), fontSize: 10)),
                    const SizedBox(height: 4),
                    Text('${match.oddsOver}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB2B7),
                            fontSize: 14)),
                  ],
                ),
                Column(
                  children: [
                    const Text('TIỀN XỈU (UNDER)',
                        style:
                            TextStyle(color: Color(0xFFE2BEBF), fontSize: 10)),
                    const SizedBox(height: 4),
                    Text('${match.oddsUnder}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFB95A),
                            fontSize: 14)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB2B7),
                      side: const BorderSide(color: Color(0xFFFFB2B7)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa kèo'),
                    onPressed: () => _showEditOddsDialog(context, match),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB95A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.gavel, size: 16),
                    label: const Text('Cưỡng chế'),
                    onPressed: () => _showOverrideDialog(context, match),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Edit Odds Dialog
  void _showEditOddsDialog(BuildContext context, MatchModel match) {
    _oddsOverController.text = match.oddsOver.toString();
    _oddsUnderController.text = match.oddsUnder.toString();
    _lineController.text = match.overUnderLine.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2020),
        title: const Text('Chỉnh sửa tỷ lệ cược',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _lineController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mốc Tài Xỉu (ví dụ: 2.5)',
                labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
              ),
            ),
            TextField(
              controller: _oddsOverController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Odds Tài (ví dụ: 1.85)',
                labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
              ),
            ),
            TextField(
              controller: _oddsUnderController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Odds Xỉu (ví dụ: 1.95)',
                labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB2B7),
                foregroundColor: const Color(0xFF67001C)),
            child: const Text('Lưu'),
            onPressed: () {
              final line =
                  double.tryParse(_lineController.text) ?? match.overUnderLine;
              final over =
                  double.tryParse(_oddsOverController.text) ?? match.oddsOver;
              final under =
                  double.tryParse(_oddsUnderController.text) ?? match.oddsUnder;

              ref.read(matchProvider.notifier).adminUpdateOdds(
                    matchId: match.id,
                    oddsOver: over,
                    oddsUnder: under,
                    overUnderLine: line,
                  );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Result Override Dialog
  void _showOverrideDialog(BuildContext context, MatchModel match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E2020),
        title: const Text('Cưỡng chế kết quả trận đấu',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Chọn kết quả bạn muốn cưỡng chế để thanh toán các kèo đặt cược liên quan:',
          style: TextStyle(color: Color(0xFFE2BEBF)),
        ),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC536D),
                    foregroundColor: Colors.white),
                onPressed: () {
                  ref
                      .read(matchProvider.notifier)
                      .adminOverrideResult(match.id, MatchResult.over);
                  Navigator.pop(context);
                },
                child: const Text('TÀI (OVER)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB95A),
                    foregroundColor: Colors.black),
                onPressed: () {
                  ref
                      .read(matchProvider.notifier)
                      .adminOverrideResult(match.id, MatchResult.push);
                  Navigator.pop(context);
                },
                child: const Text('HÒA (PUSH)'),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF28DFB5),
                    foregroundColor: Colors.black),
                onPressed: () {
                  ref
                      .read(matchProvider.notifier)
                      .adminOverrideResult(match.id, MatchResult.under);
                  Navigator.pop(context);
                },
                child: const Text('XỈU (UNDER)'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy',
                    style: TextStyle(color: Color(0xFFE2BEBF))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Create Simulated Match Dialog
  void _showCreateMatchDialog(BuildContext context) {
    _homeController.clear();
    _awayController.clear();
    _oddsOverController.text = '1.85';
    _oddsUnderController.text = '1.95';
    _lineController.text = '2.5';

    showDialog(
      context: context,
      builder: (context) {
        DateTime matchDateTime = DateTime.now().add(const Duration(hours: 2));
        final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            backgroundColor: const Color(0xFF1E2020),
            title: const Text('Tạo trận đấu giả lập mới',
                style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _homeController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Đội nhà (Home Team)',
                      labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
                    ),
                  ),
                  TextField(
                    controller: _awayController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Đội khách (Away Team)',
                      labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
                    ),
                  ),
                  TextField(
                    controller: _lineController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Mốc Tài Xỉu (ví dụ: 2.5)',
                      labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
                    ),
                  ),
                  TextField(
                    controller: _oddsOverController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Odds Tài (ví dụ: 1.85)',
                      labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
                    ),
                  ),
                  TextField(
                    controller: _oddsUnderController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Odds Xỉu (ví dụ: 1.95)',
                      labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('• Thời gian thi đấu',
                        style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 12)),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: matchDateTime,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: Color(0xFFE94560),
                              surface: Color(0xFF1E2020),
                            ),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(matchDateTime),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: Color(0xFFE94560),
                                surface: Color(0xFF1E2020),
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (time != null) {
                          setDialogState(() {
                            matchDateTime = DateTime(
                              date.year, date.month, date.day,
                              time.hour, time.minute,
                            );
                          });
                        }
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2A3A),
                        border: Border.all(color: const Color(0xFFE94560).withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateFormat.format(matchDateTime),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.calendar_today,
                              color: Color(0xFFE94560), size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB2B7),
                    foregroundColor: const Color(0xFF67001C)),
                child: const Text('Tạo trận'),
                onPressed: () {
                  final home = _homeController.text.trim();
                  final away = _awayController.text.trim();
                  final line =
                      double.tryParse(_lineController.text) ?? 2.5;
                  final over =
                      double.tryParse(_oddsOverController.text) ?? 1.85;
                  final under =
                      double.tryParse(_oddsUnderController.text) ?? 1.95;

                  if (home.isNotEmpty && away.isNotEmpty) {
                    final match = MatchModel(
                      id: 'sim_${matchDateTime.millisecondsSinceEpoch}',
                      homeTeam: home,
                      awayTeam: away,
                      utcDate: matchDateTime,
                      status: MatchStatus.scheduled,
                      scoreHome: 0,
                      scoreAway: 0,
                      oddsOver: over,
                      oddsUnder: under,
                      overUnderLine: line,
                      isSimulated: true,
                    );
                    ref
                        .read(matchProvider.notifier)
                        .createSimulatedMatch(match);
                  }
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // VIEW: TAB 3 - DETAILED ACTIVITY LOGS VIEW
  // ==========================================
  Widget _buildLogsTab(AdminState adminState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nhật ký hoạt động hệ thống',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE2E2E2),
              fontFamily: 'Inter'),
        ),
        const SizedBox(height: 4),
        const Text(
          'Lịch sử các thao tác can thiệp kết quả hoặc giao dịch rút tiền của Ban quản trị.',
          style: TextStyle(fontSize: 13, color: Color(0xFFE2BEBF)),
        ),
        const SizedBox(height: 24),
        if (adminState.adminLogs.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0),
              child: Text(
                'Không có hoạt động nào được ghi nhận',
                style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 14),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: adminState.adminLogs.length,
            itemBuilder: (context, index) {
              final log = adminState.adminLogs[index];
              final action = log['action'];
              final timestamp = log['timestamp'] as DateTime;
              final details = log['details'] as Map<String, dynamic>;

              final timeStr =
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp);

              String message = '';
              Color actionColor = const Color(0xFFFFB2B7);
              IconData icon = Icons.info_outline;

              if (action == 'OVERRIDE_MATCH_RESULT') {
                message =
                    'Ghi đè kết quả trận đấu ${details['matchId']} thành: ${details['result']}';
                actionColor = const Color(0xFFFFB95A);
                icon = Icons.gavel;
              } else if (action == 'UPDATE_MATCH_ODDS') {
                message =
                    'Chỉnh sửa tỷ lệ cược trận ${details['matchId']}: Tài/Xỉu mốc ${details['overUnderLine']} (Odds: ${details['oddsOver']} / ${details['oddsUnder']})';
                actionColor = const Color(0xFFFFB2B7);
                icon = Icons.edit_note;
              } else if (action == 'OVERRIDE_BET_STATUS') {
                message =
                    'Admin ghi đè trạng thái cược ${details['betId']} sang: ${details['status']}';
                actionColor = const Color(0xFFFC536D);
                icon = Icons.warning_amber;
              } else {
                message = 'Hành động: $action - ${details.toString()}';
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: _buildGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: actionColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: actionColor, size: 18),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: actionColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    action,
                                    style: TextStyle(
                                        color: actionColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                      color: Color(0xFFE2BEBF), fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              message,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFFE2E2E2)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
