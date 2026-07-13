import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/admin/admin_provider.dart';
import '../../application/admin/admin_state.dart';
import '../../application/admin/admin_notifier.dart';
import '../../application/matches/match_provider.dart';
import '../../application/auth/auth_provider.dart';
import '../../application/bets/bet_provider.dart';
import '../../application/bets/dice_provider.dart';
import '../../domain/models/match_model.dart';
import '../../domain/models/user_model.dart';
import '../../domain/enums/match_status.dart';
import '../../domain/enums/session_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/betting_session_model.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _currentTab = 0; // 0: Dashboard, 1: Players, 2: Matches, 3: Tài Xỉu, 4: Logs
  int _taiXiuSubTab = 0; // 0: Sessions, 1: Bets
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

  // Dialog điều chỉnh kèo Tài Xỉu
  Future<void> _editSessionOddsDialog(BuildContext context, BettingSessionModel session) async {
    final oddsOverCtrl = TextEditingController(text: session.oddsOver.toString());
    final oddsUnderCtrl = TextEditingController(text: session.oddsUnder.toString());
    final lineCtrl = TextEditingController(text: session.overUnderLine.toString());

    final updated = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2020),
          title: const Text(
            'Điều chỉnh kèo Tài Xỉu',
            style: TextStyle(
              color: Color(0xFFE2E2E2),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oddsOverCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tỷ lệ cược TÀI (Odds Over)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: oddsUnderCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tỷ lệ cược XỈU (Odds Under)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lineCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Dòng cược (Over Under Line)',
                  labelStyle: TextStyle(color: Colors.white70),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF00D4AA)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: Colors.black,
              ),
              child: const Text('Cập nhật', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (updated == true) {
      final oddsOver = double.tryParse(oddsOverCtrl.text);
      final oddsUnder = double.tryParse(oddsUnderCtrl.text);
      final line = double.tryParse(lineCtrl.text);

      if (oddsOver == null || oddsUnder == null || line == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập số hợp lệ'),
            backgroundColor: Color(0xFFFC536D),
          ),
        );
        return;
      }

      try {
        await ref.read(diceSessionServiceProvider).updateSessionOdds(
              sessionId: session.sessionId,
              oddsOver: oddsOver,
              oddsUnder: oddsUnder,
              overUnderLine: line,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật kèo Tài Xỉu thành công!'),
            backgroundColor: Color(0xFF00D4AA),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật: $e'),
            backgroundColor: const Color(0xFFFC536D),
          ),
        );
      }
    }
  }

  // Active Betting Session UI Card for Admin Panel
  Widget _buildActiveSessionCard(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(diceActiveSessionProvider);
    final countdown = ref.watch(diceCountdownProvider);
    final status = ref.watch(diceSessionStatusProvider);
    final user = ref.read(currentUserProvider);
    final adminId = user?.uid ?? 'admin';

    if (activeSession == null) {
      return _buildGlassCard(
        child: const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text(
              'Không có phiên cược Tài Xỉu nào đang chạy.',
              style: TextStyle(color: Color(0xFFE2BEBF), fontSize: 13),
            ),
          ),
        ),
      );
    }

    final isButtonsActive = status == SessionStatus.open || status == SessionStatus.locked;
    final totalPool = activeSession.totalOverBets + activeSession.totalUnderBets;
    final overPct = totalPool > 0 ? (activeSession.totalOverBets / totalPool * 100).round() : 50;
    final underPct = 100 - overPct;

    return _buildGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Phiên cược đang chạy #${activeSession.sessionNumber}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE2E2E2),
                          fontFamily: 'Inter',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Color(0xFF00D4AA)),
                        onPressed: () => _editSessionOddsDialog(context, activeSession),
                        tooltip: 'Điều chỉnh kèo Tài Xỉu',
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      if (activeSession.isAdminOverride) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFC536D),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ADMIN OVERRIDE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đếm ngược: $countdown giây (${status.name.toUpperCase()})',
                    style: TextStyle(
                      fontSize: 12,
                      color: status == SessionStatus.locked ? const Color(0xFFFFB347) : const Color(0xFFE2BEBF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kèo: ${activeSession.overUnderLine} (Tài: x${activeSession.oddsOver} | Xỉu: x${activeSession.oddsUnder})',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFA0A0B0),
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 36,
                height: 36,
                child: Stack(
                  children: [
                    CircularProgressIndicator(
                      value: countdown / 60,
                      backgroundColor: const Color(0xFF333535),
                      valueColor: AlwaysStoppedAnimation(
                        status == SessionStatus.locked ? const Color(0xFFFFB347) : const Color(0xFF00D4AA),
                      ),
                      strokeWidth: 3,
                    ),
                    Center(
                      child: Text(
                        '$countdown',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TỔNG CƯỢC XỈU',
                      style: TextStyle(fontSize: 10, color: Color(0xFFA0A0B0), letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(activeSession.totalUnderBets),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00D4AA)),
                    ),
                    Text(
                      '$underPct%',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF00D4AA)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'TỔNG CƯỢC TÀI',
                      style: TextStyle(fontSize: 10, color: Color(0xFFA0A0B0), letterSpacing: 0.8),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(activeSession.totalOverBets),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFFC536D)),
                    ),
                    Text(
                      '$overPct%',
                      style: const TextStyle(fontSize: 10, color: Color(0xFFFC536D)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !isButtonsActive
                      ? null
                      : () async {
                          try {
                            await ref.read(diceSessionServiceProvider).adminOverrideResult(
                                  sessionId: activeSession.sessionId,
                                  result: 'under',
                                  adminId: adminId,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cưỡng chế kết quả XỈU thành công!'),
                                backgroundColor: Color(0xFF00D4AA),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: const Color(0xFFFC536D),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4AA).withOpacity(0.1),
                    foregroundColor: const Color(0xFF00D4AA),
                    side: const BorderSide(color: Color(0xFF00D4AA)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_downward, size: 16),
                  label: const Text(
                    'Force XỈU',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: !isButtonsActive
                      ? null
                      : () async {
                          try {
                            await ref.read(diceSessionServiceProvider).adminOverrideResult(
                                  sessionId: activeSession.sessionId,
                                  result: 'over',
                                  adminId: adminId,
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Đã cưỡng chế kết quả TÀI thành công!'),
                                backgroundColor: Color(0xFFFC536D),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: const Color(0xFFFC536D),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFC536D).withOpacity(0.1),
                    foregroundColor: const Color(0xFFFC536D),
                    side: const BorderSide(color: Color(0xFFFC536D)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text(
                    'Force TÀI',
                    style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentTab,
                  backgroundColor: const Color(0xFF1E2020),
                  selectedItemColor: const Color(0xFFFFB2B7),
                  unselectedItemColor: const Color(0xFFE2BEBF).withOpacity(0.6),
                  type: BottomNavigationBarType.fixed,
                  selectedFontSize: 12,
                  unselectedFontSize: 10,
                  iconSize: 22,
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
                      icon: Icon(Icons.casino_outlined),
                      activeIcon: Icon(Icons.casino),
                      label: 'Tài Xỉu',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.terminal_outlined),
                      activeIcon: Icon(Icons.terminal),
                      label: 'Nhật ký',
                    ),
                  ],
                ),
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
                  icon: Icons.casino,
                  label: 'Cược Tài Xỉu',
                  index: 3,
                ),
                _buildSidebarItem(
                  icon: Icons.terminal,
                  label: 'System Logs',
                  index: 4,
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
          Row(
            children: [
              const IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFFE2E2E2),
                ),
                onPressed: null,
              ),
              IconButton(
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Color(0xFFE2E2E2),
                  ),
                  tooltip: 'Cấu hình Admin',
                  onPressed: () {
                    _showAdminSettingsDialog(context);
                  }),
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
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFFE2E2E2),
                ),
                tooltip: 'Cấu hình Admin',
                onPressed: () {
                  _showAdminSettingsDialog(context);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFFFC536D),
                ),
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _currentTab = 1;
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
                      fontSize: 13,
                    ),
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
        return _buildMatchesTab(
          adminState,
          adminNotifier,
          liveMatches,
          scheduledMatches,
        );
      case 3:
        return _buildTaiXiuTab(adminState, adminNotifier);
      case 4:
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

        // Active Betting Session Card
        _buildActiveSessionCard(context, ref),
        const SizedBox(height: 24),

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
                  Row(
                    children: [
                      if (adminState.users.isNotEmpty)
                        TextButton.icon(
                          onPressed: () async {
                            final firstUser = adminState.users.first;
                            try {
                              await adminNotifier.seedMockRequests(
                                firstUser.uid,
                                firstUser.displayName,
                              );
                            } catch (error) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Không thể tạo dữ liệu mẫu: $error',
                                  ),
                                  backgroundColor: const Color(0xFFFC536D),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.add, size: 14),
                          label: const Text('Seed Mock',
                              style: TextStyle(fontSize: 11)),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFFFB2B7),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                          ),
                        ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _currentTab = 1; // Switch to player list
                          });
                        },
                        child: const Text('Xem tất cả',
                            style: TextStyle(color: Color(0xFFFFB2B7))),
                      ),
                    ],
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
                            backgroundColor:
                                const Color(0xFFFFB2B7).withOpacity(0.1),
                            child: Text(
                              displayName.isNotEmpty
                                  ? displayName[0].toUpperCase()
                                  : 'U',
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
                    return _buildMatchAdminCard(
                      match,
                      adminState,
                      adminNotifier,
                    );
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
                        _currentTab = 4; // Switch to logs tab
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
                        const SizedBox(width: 12),
                        // Toggle Admin privilege
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFFB95A),
                            side: const BorderSide(color: Color(0xFFFFB95A)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon:
                              const Icon(Icons.admin_panel_settings, size: 16),
                          label: Text(
                              user.isAdmin ? 'Thu hồi Admin' : 'Cấp Admin'),
                          onPressed: () {
                            adminNotifier.toggleAdminStatus(
                                user.uid, !user.isAdmin);
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
  MatchModel _matchFromAdminMap(
    Map<String, dynamic> data,
  ) {
    final statusName = data['status']?.toString() ?? MatchStatus.scheduled.name;

    final status = MatchStatus.values.firstWhere(
      (item) => item.name == statusName,
      orElse: () => MatchStatus.scheduled,
    );

    MatchResult? result;
    final resultName = data['result']?.toString();

    if (resultName != null && resultName.isNotEmpty) {
      result = MatchResult.values.firstWhere(
        (item) => item.name == resultName,
        orElse: () => MatchResult.push,
      );
    }

    final rawDate = data['utcDate'];
    DateTime utcDate = DateTime.now();

    if (rawDate is DateTime) {
      utcDate = rawDate;
    } else if (rawDate is String) {
      utcDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    }

    return MatchModel(
      id: data['id']?.toString() ?? '',
      homeTeam: data['homeTeam']?.toString() ?? '',
      awayTeam: data['awayTeam']?.toString() ?? '',
      utcDate: utcDate,
      status: status,
      scoreHome: (data['scoreHome'] as num?)?.toInt() ?? 0,
      scoreAway: (data['scoreAway'] as num?)?.toInt() ?? 0,
      result: result,
      oddsOver: (data['oddsOver'] as num?)?.toDouble() ?? 1.85,
      oddsUnder: (data['oddsUnder'] as num?)?.toDouble() ?? 1.95,
      overUnderLine: (data['overUnderLine'] as num?)?.toDouble() ?? 2.5,
      isSimulated: data['isSimulated'] as bool? ?? false,
    );
  }

  Widget _buildMatchesTab(
    AdminState adminState,
    AdminNotifier adminNotifier,
    List<MatchModel> ignoredLiveMatches,
    List<MatchModel> ignoredScheduledMatches,
  ) {
    final allMatches = adminState.matches
        .map(_matchFromAdminMap)
        .where((match) => match.id.isNotEmpty)
        .toList();

    final liveMatches = allMatches
        .where(
          (match) => match.status == MatchStatus.inPlay,
        )
        .toList();

    final scheduledMatches = allMatches
        .where(
          (match) => match.status == MatchStatus.scheduled,
        )
        .toList();

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
              return _buildMatchAdminCard(
                match,
                adminState,
                adminNotifier,
              );
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
              return _buildMatchAdminCard(
                match,
                adminState,
                adminNotifier,
              );
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

  Widget _buildMatchAdminCard(
    MatchModel match,
    AdminState adminState,
    AdminNotifier adminNotifier,
  ) {
    final format = DateFormat('dd/MM HH:mm');
    final timeStr = format.format(match.utcDate);
    final firestoreMatch =
        adminState.matches.cast<Map<String, dynamic>?>().firstWhere(
              (item) => item?['id']?.toString() == match.id,
              orElse: () => null,
            );

    final isBettingLocked =
        firestoreMatch?['isBettingLocked'] as bool? ?? false;

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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 180,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFFB2B7),
                      side: const BorderSide(color: Color(0xFFFFB2B7)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Sửa kèo'),
                    onPressed: () => _showEditOddsDialog(
                      context,
                      match,
                      adminNotifier,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB95A),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.gavel, size: 16),
                    label: const Text('Sửa kết quả'),
                    onPressed: () => _showOverrideDialog(
                      context,
                      match,
                      adminNotifier,
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isBettingLocked
                          ? const Color(0xFF28DFB5)
                          : const Color(0xFFFC536D),
                      foregroundColor:
                          isBettingLocked ? Colors.black : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(
                      isBettingLocked ? Icons.lock_open : Icons.lock,
                      size: 16,
                    ),
                    label: Text(
                      isBettingLocked ? 'Mở cược' : 'Khóa cược',
                    ),
                    onPressed: () {
                      adminNotifier.updateMatchBettingLock(
                        matchId: match.id,
                        isLocked: !isBettingLocked,
                      );
                    },
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
  void _showEditOddsDialog(
    BuildContext context,
    MatchModel match,
    AdminNotifier adminNotifier,
  ) {
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Mốc Tài Xỉu (ví dụ: 2.5)',
                labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
              ),
            ),
            TextField(
              controller: _oddsOverController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Odds Tài (ví dụ: 1.85)',
                labelStyle: TextStyle(color: Color(0xFFE2BEBF)),
              ),
            ),
            TextField(
              controller: _oddsUnderController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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

              adminNotifier.updateMatchOdds(
                matchId: match.id,
                overOdds: over,
                underOdds: under,
                line: line,
              );
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  // Result Override Dialog
  void _showOverrideDialog(
    BuildContext context,
    MatchModel match,
    AdminNotifier adminNotifier,
  ) {
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
                  adminNotifier.forceMatchResult(
                    matchId: match.id,
                    result: 'over',
                  );
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
                  adminNotifier.forceMatchResult(
                    matchId: match.id,
                    result: 'draw',
                  );
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
                  adminNotifier.forceMatchResult(
                    matchId: match.id,
                    result: 'under',
                  );
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

              if (action == 'OVERRIDE_MATCH_RESULT' ||
                  action == 'FORCE_RESULT') {
                message =
                    'Ghi đè kết quả trận đấu ${details['matchId']} thành: ${details['result']}';
                actionColor = const Color(0xFFFFB95A);
                icon = Icons.gavel;
              } else if (action == 'UPDATE_MATCH_ODDS' ||
                  action == 'UPDATE_ODDS') {
                message =
                    'Chỉnh sửa tỷ lệ cược trận ${details['matchId']}: Tài/Xỉu mốc ${details['overUnderLine'] ?? ''}';
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

  void _showAdminSettingsDialog(BuildContext context) {
    final adminState = ref.read(adminProvider);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không tìm thấy tài khoản Admin hiện tại.'),
          backgroundColor: Color(0xFFFC536D),
        ),
      );
      return;
    }

    final antiSettings = adminState.antiGamblingSettings;
    final educationContent = adminState.educationContent;

    bool antiEnabled = antiSettings['enabled'] as bool? ?? true;

    bool educationEnabled = educationContent['enabled'] as bool? ?? true;

    final warningController = TextEditingController(
      text: ((antiSettings['warningLossThreshold'] as num?)?.toDouble() ?? 30.0)
          .toStringAsFixed(0),
    );

    final criticalController = TextEditingController(
      text:
          ((antiSettings['criticalLossThreshold'] as num?)?.toDouble() ?? 50.0)
              .toStringAsFixed(0),
    );

    final maximumBetsController = TextEditingController(
      text: ((antiSettings['maximumBetsPerDay'] as num?)?.toInt() ?? 20)
          .toString(),
    );

    final breakMinutesController = TextEditingController(
      text: ((antiSettings['breakMinutes'] as num?)?.toInt() ?? 15).toString(),
    );

    final titleController = TextEditingController(
      text: educationContent['title']?.toString() ??
          'Hãy dừng lại trước khi quá muộn',
    );

    final descriptionController = TextEditingController(
      text: educationContent['description']?.toString() ??
          'Cá cược không phải là cách kiếm tiền. '
              'Khi bạn cố gỡ lại số tiền đã mất, nguy cơ thua lỗ '
              'và mất kiểm soát sẽ ngày càng cao.',
    );

    final videoUrlController = TextEditingController(
      text: educationContent['videoUrl']?.toString() ?? '',
    );

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final screenWidth = MediaQuery.of(context).size.width;

            final dialogWidth = screenWidth > 700 ? 650.0 : screenWidth * 0.92;

            return AlertDialog(
              backgroundColor: const Color(0xFF1E2020),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: const Color(0xFFFFB2B7).withOpacity(0.18),
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(
                24,
                22,
                16,
                8,
              ),
              contentPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                8,
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                24,
                8,
                24,
                20,
              ),
              title: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB2B7).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_outlined,
                      color: Color(0xFFFFB2B7),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cấu hình hệ thống',
                          style: TextStyle(
                            color: Color(0xFFE2E2E2),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Anti-Gambling và nội dung giáo dục',
                          style: TextStyle(
                            color: Color(0xFFE2BEBF),
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Color(0xFFE2BEBF),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: dialogWidth,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSettingsSectionHeader(
                        icon: Icons.health_and_safety_outlined,
                        title: '11.8 - Cấu hình Anti-Gambling',
                        description: 'Thiết lập các giới hạn giúp cảnh báo '
                            'và giảm hành vi cá cược mất kiểm soát.',
                        color: const Color(0xFFFC536D),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFA9898A).withOpacity(0.15),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: antiEnabled,
                          activeThumbColor: const Color(0xFF28DFB5),
                          activeTrackColor:
                              const Color(0xFF28DFB5).withOpacity(0.35),
                          title: const Text(
                            'Bật hệ thống Anti-Gambling',
                            style: TextStyle(
                              color: Color(0xFFE2E2E2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            antiEnabled
                                ? 'Hệ thống cảnh báo đang hoạt động'
                                : 'Hệ thống cảnh báo đang tạm tắt',
                            style: TextStyle(
                              color: antiEnabled
                                  ? const Color(0xFF28DFB5)
                                  : const Color(0xFFE2BEBF),
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              antiEnabled = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 520;

                          final warningField = _buildSettingsNumberField(
                            controller: warningController,
                            label: 'Ngưỡng cảnh báo',
                            hintText: 'Ví dụ: 30',
                            suffixText: '%',
                            icon: Icons.warning_amber_rounded,
                            enabled: antiEnabled,
                          );

                          final criticalField = _buildSettingsNumberField(
                            controller: criticalController,
                            label: 'Ngưỡng nguy hiểm',
                            hintText: 'Ví dụ: 50',
                            suffixText: '%',
                            icon: Icons.dangerous_outlined,
                            enabled: antiEnabled,
                          );

                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(child: warningField),
                                const SizedBox(width: 12),
                                Expanded(child: criticalField),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              warningField,
                              const SizedBox(height: 12),
                              criticalField,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 520;

                          final maximumField = _buildSettingsNumberField(
                            controller: maximumBetsController,
                            label: 'Số cược tối đa/ngày',
                            hintText: 'Ví dụ: 20',
                            suffixText: 'cược',
                            icon: Icons.receipt_long_outlined,
                            enabled: antiEnabled,
                            allowDecimal: false,
                          );

                          final breakField = _buildSettingsNumberField(
                            controller: breakMinutesController,
                            label: 'Thời gian nghỉ bắt buộc',
                            hintText: 'Ví dụ: 15',
                            suffixText: 'phút',
                            icon: Icons.timer_outlined,
                            enabled: antiEnabled,
                            allowDecimal: false,
                          );

                          if (isWide) {
                            return Row(
                              children: [
                                Expanded(child: maximumField),
                                const SizedBox(width: 12),
                                Expanded(child: breakField),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              maximumField,
                              const SizedBox(height: 12),
                              breakField,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB95A).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFFFB95A).withOpacity(0.28),
                          ),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Color(0xFFFFB95A),
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'Ngưỡng nguy hiểm phải lớn hơn hoặc '
                                'bằng ngưỡng cảnh báo. Các tỷ lệ được '
                                'tính theo phần trăm thua lỗ.',
                                style: TextStyle(
                                  color: Color(0xFFE2BEBF),
                                  fontSize: 12,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Divider(
                        color: const Color(0xFFA9898A).withOpacity(0.18),
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSectionHeader(
                        icon: Icons.school_outlined,
                        title: '11.9 - Nội dung giáo dục',
                        description: 'Quản lý nội dung cảnh báo và video '
                            'giáo dục hiển thị cho người chơi.',
                        color: const Color(0xFFFFB95A),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFA9898A).withOpacity(0.15),
                          ),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: educationEnabled,
                          activeThumbColor: const Color(0xFF28DFB5),
                          activeTrackColor:
                              const Color(0xFF28DFB5).withOpacity(0.35),
                          title: const Text(
                            'Hiển thị nội dung giáo dục',
                            style: TextStyle(
                              color: Color(0xFFE2E2E2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            educationEnabled
                                ? 'Nội dung đang được hiển thị'
                                : 'Nội dung đang bị ẩn',
                            style: TextStyle(
                              color: educationEnabled
                                  ? const Color(0xFF28DFB5)
                                  : const Color(0xFFE2BEBF),
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (value) {
                            setDialogState(() {
                              educationEnabled = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildSettingsTextField(
                        controller: titleController,
                        label: 'Tiêu đề cảnh báo',
                        hintText: 'Ví dụ: Hãy dừng lại trước khi quá muộn',
                        icon: Icons.title,
                        enabled: educationEnabled,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsTextField(
                        controller: descriptionController,
                        label: 'Nội dung giáo dục',
                        hintText: 'Nhập nội dung cảnh báo dành cho người chơi',
                        icon: Icons.article_outlined,
                        enabled: educationEnabled,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 12),
                      _buildSettingsTextField(
                        controller: videoUrlController,
                        label: 'Link video giáo dục',
                        hintText:
                            'https://youtube.com/... hoặc https://tiktok.com/...',
                        icon: Icons.video_library_outlined,
                        enabled: educationEnabled,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF121414),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFA9898A).withOpacity(0.15),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.preview_outlined,
                                  color: Color(0xFFFFB2B7),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Xem trước nội dung',
                                  style: TextStyle(
                                    color: Color(0xFFE2E2E2),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              titleController.text.trim().isEmpty
                                  ? 'Chưa có tiêu đề'
                                  : titleController.text.trim(),
                              style: const TextStyle(
                                color: Color(0xFFFFB95A),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              descriptionController.text.trim().isEmpty
                                  ? 'Chưa có nội dung giáo dục'
                                  : descriptionController.text.trim(),
                              style: const TextStyle(
                                color: Color(0xFFE2BEBF),
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                            if (videoUrlController.text.trim().isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.link,
                                    color: Color(0xFF28DFB5),
                                    size: 17,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      videoUrlController.text.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF28DFB5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text(
                    'Hủy',
                    style: TextStyle(
                      color: Color(0xFFE2BEBF),
                    ),
                  ),
                ),
                Consumer(
                  builder: (context, ref, child) {
                    final isLoading = ref.watch(
                      adminProvider.select(
                        (state) => state.isLoading,
                      ),
                    );

                    return ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () async {
                              final warning = double.tryParse(
                                warningController.text
                                    .trim()
                                    .replaceAll(',', '.'),
                              );

                              final critical = double.tryParse(
                                criticalController.text
                                    .trim()
                                    .replaceAll(',', '.'),
                              );

                              final maximumBets = int.tryParse(
                                maximumBetsController.text.trim(),
                              );

                              final breakMinutes = int.tryParse(
                                breakMinutesController.text.trim(),
                              );

                              if (warning == null ||
                                  critical == null ||
                                  maximumBets == null ||
                                  breakMinutes == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Vui lòng nhập đúng định dạng '
                                      'cho các giá trị cấu hình.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              if (warning < 0 ||
                                  critical < 0 ||
                                  warning > 100 ||
                                  critical > 100) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ngưỡng cảnh báo phải nằm '
                                      'trong khoảng từ 0 đến 100%.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              if (critical < warning) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Ngưỡng nguy hiểm phải lớn hơn '
                                      'hoặc bằng ngưỡng cảnh báo.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              if (maximumBets < 1 || breakMinutes < 1) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Số cược tối đa và thời gian '
                                      'nghỉ phải lớn hơn 0.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              if (titleController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Tiêu đề giáo dục không được '
                                      'để trống.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              if (descriptionController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nội dung giáo dục không được '
                                      'để trống.',
                                    ),
                                    backgroundColor: Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              final notifier = ref.read(
                                adminProvider.notifier,
                              );

                              await notifier.updateAntiGamblingSettings(
                                adminId: currentUser.uid,
                                warningLossThreshold: warning,
                                criticalLossThreshold: critical,
                                maximumBetsPerDay: maximumBets,
                                breakMinutes: breakMinutes,
                                enabled: antiEnabled,
                              );

                              final antiError =
                                  ref.read(adminProvider).errorMessage;

                              if (antiError != null) {
                                if (!context.mounted) {
                                  return;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(antiError),
                                    backgroundColor: const Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              await notifier.updateEducationContent(
                                adminId: currentUser.uid,
                                title: titleController.text,
                                description: descriptionController.text,
                                videoUrl: videoUrlController.text,
                                enabled: educationEnabled,
                              );

                              final educationError =
                                  ref.read(adminProvider).errorMessage;

                              if (!context.mounted) {
                                return;
                              }

                              if (educationError != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(educationError),
                                    backgroundColor: const Color(0xFFFC536D),
                                  ),
                                );
                                return;
                              }

                              Navigator.pop(dialogContext);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đã lưu cấu hình Anti-Gambling '
                                    'và nội dung giáo dục.',
                                  ),
                                  backgroundColor: const Color(0xFF28DFB5),
                                ),
                              );
                            },
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF67001C),
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        isLoading ? 'Đang lưu...' : 'Lưu cấu hình',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB2B7),
                        foregroundColor: const Color(0xFF67001C),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSettingsSectionHeader({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE2E2E2),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  color: Color(0xFFE2BEBF),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsNumberField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required String suffixText,
    required IconData icon,
    required bool enabled,
    bool allowDecimal = true,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.numberWithOptions(
        decimal: allowDecimal,
      ),
      style: const TextStyle(
        color: Color(0xFFE2E2E2),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        suffixText: suffixText,
        prefixIcon: Icon(
          icon,
          color: enabled ? const Color(0xFFFFB2B7) : const Color(0xFF6E6667),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFE2BEBF),
        ),
        hintStyle: TextStyle(
          color: const Color(0xFFE2BEBF).withOpacity(0.45),
        ),
        suffixStyle: const TextStyle(
          color: Color(0xFFFFB95A),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: enabled
            ? const Color(0xFF121414)
            : const Color(0xFF121414).withOpacity(0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFA9898A).withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFA9898A).withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFFB2B7),
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFA9898A).withOpacity(0.08),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required bool enabled,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: Color(0xFFE2E2E2),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        alignLabelWithHint: maxLines > 1,
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 72 : 0,
          ),
          child: Icon(
            icon,
            color: enabled ? const Color(0xFFFFB2B7) : const Color(0xFF6E6667),
          ),
        ),
        labelStyle: const TextStyle(
          color: Color(0xFFE2BEBF),
        ),
        hintStyle: TextStyle(
          color: const Color(0xFFE2BEBF).withOpacity(0.45),
        ),
        filled: true,
        fillColor: enabled
            ? const Color(0xFF121414)
            : const Color(0xFF121414).withOpacity(0.45),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFA9898A).withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFFFFB2B7),
            width: 1.4,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: const Color(0xFFA9898A).withOpacity(0.08),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // VIEW: TAB 3 - TÀI XỈU VIEW
  // ==========================================
  Widget _buildTaiXiuTab(AdminState adminState, AdminNotifier adminNotifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Quản lý Cược Tài Xỉu',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE2E2E2),
                fontFamily: 'Inter',
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _taiXiuSubTab = 0;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _taiXiuSubTab == 0
                        ? const Color(0xFFFFB2B7)
                        : const Color(0xFF1E2020),
                    foregroundColor: _taiXiuSubTab == 0
                        ? Colors.black
                        : const Color(0xFFE2E2E2),
                    side: const BorderSide(color: Color(0xFF333535)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Lịch sử Phiên', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _taiXiuSubTab = 1;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _taiXiuSubTab == 1
                        ? const Color(0xFFFFB2B7)
                        : const Color(0xFF1E2020),
                    foregroundColor: _taiXiuSubTab == 1
                        ? Colors.black
                        : const Color(0xFFE2E2E2),
                    side: const BorderSide(color: Color(0xFF333535)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  child: const Text('Đơn cược', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _taiXiuSubTab == 0
            ? _buildTaiXiuSessionsSubTab()
            : _buildTaiXiuBetsSubTab(),
      ],
    );
  }

  // Sub-Tab 1: Lịch sử và trạng thái các phiên cược
  Widget _buildTaiXiuSessionsSubTab() {
    final bettingService = ref.read(diceSessionServiceProvider);
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('betting_sessions')
          .orderBy('sessionNumber', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có phiên cược nào được tạo.',
              style: TextStyle(color: Color(0xFFE2BEBF)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final sessionId = doc.id;
            final data = doc.data() as Map<String, dynamic>;
            final sessionNumber = data['sessionNumber'] as int? ?? 0;
            final statusStr = data['status'] as String? ?? 'settled';
            final result = data['result'] as String? ?? 'none';
            final oddsOver = (data['oddsOver'] as num? ?? 1.85).toDouble();
            final oddsUnder = (data['oddsUnder'] as num? ?? 1.95).toDouble();
            final line = (data['overUnderLine'] as num? ?? 2.5).toDouble();
            final totalOver = (data['totalOverBets'] as num? ?? 0).toDouble();
            final totalUnder = (data['totalUnderBets'] as num? ?? 0).toDouble();
            final startedAtVal = data['startedAt'];
            final startedAt = startedAtVal is Timestamp
                ? startedAtVal.toDate()
                : DateTime.now();

            final displayTime = DateFormat('HH:mm:ss dd/MM').format(startedAt);

            Color statusColor = const Color(0xFF00D4AA);
            if (statusStr == 'locked') {
              statusColor = const Color(0xFFFFB347);
            } else if (statusStr == 'settled') {
              statusColor = const Color(0xFFA0A0B0);
            }

            return _buildGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phiên #$sessionNumber (Bắt đầu: $displayTime)',
                            style: const TextStyle(
                              color: Color(0xFFE2E2E2),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ID: $sessionId',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: statusColor.withOpacity(0.4)),
                        ),
                        child: Text(
                          statusStr.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCol(
                          title: 'KÈO & ODDS',
                          value: 'Kèo $line\nTài x$oddsOver | Xỉu x$oddsUnder',
                        ),
                      ),
                      Expanded(
                        child: _buildMetricCol(
                          title: 'TỔNG CƯỢC TÀI',
                          value: _formatCurrency(totalOver),
                          valColor: const Color(0xFFFC536D),
                        ),
                      ),
                      Expanded(
                        child: _buildMetricCol(
                          title: 'TỔNG CƯỢC XỈU',
                          value: _formatCurrency(totalUnder),
                          valColor: const Color(0xFF00D4AA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Kết quả: ',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                      Text(
                        result == 'none' ? 'Chưa có' : result.toUpperCase(),
                        style: TextStyle(
                          color: result == 'over'
                              ? const Color(0xFFFC536D)
                              : (result == 'under'
                                  ? const Color(0xFF00D4AA)
                                  : Colors.white70),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      if (data['isAdminOverride'] == true) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Color(0xFFFFB347), size: 12),
                        const Text(
                          ' (Admin Force)',
                          style: TextStyle(color: Color(0xFFFFB347), fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (statusStr != 'settled') ...[
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF00D4AA), size: 20),
                          tooltip: 'Sửa kèo odds',
                          onPressed: () {
                            final sessionModel = BettingSessionModel.fromFirestore(doc);
                            _editSessionOddsDialog(context, sessionModel);
                          },
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await bettingService.adminOverrideResult(
                                sessionId: sessionId,
                                result: 'under',
                                adminId: 'admin',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Force XỈU thành công!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_downward, size: 14),
                          label: const Text('Force XỈU', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D4AA).withOpacity(0.12),
                            foregroundColor: const Color(0xFF00D4AA),
                            side: const BorderSide(color: Color(0xFF00D4AA)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              await bettingService.adminOverrideResult(
                                sessionId: sessionId,
                                result: 'over',
                                adminId: 'admin',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Force TÀI thành công!')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.arrow_upward, size: 14),
                          label: const Text('Force TÀI', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFC536D).withOpacity(0.12),
                            foregroundColor: const Color(0xFFFC536D),
                            side: const BorderSide(color: Color(0xFFFC536D)),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton.icon(
                          onPressed: () {
                            _showAdminSettleOverrideDialog(context, sessionId, result);
                          },
                          icon: const Icon(Icons.refresh, size: 14),
                          label: const Text('Sửa kết quả phiên', style: TextStyle(fontSize: 11)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB2B7).withOpacity(0.12),
                            foregroundColor: const Color(0xFFFFB2B7),
                            side: const BorderSide(color: Color(0xFFFFB2B7)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Sửa kết quả cược của phiên cược đã kết toán (tính lại ví và trạng thái)
  Future<void> _showAdminSettleOverrideDialog(BuildContext context, String sessionId, String currentResult) async {
    final newResult = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2020),
          title: const Text(
            'Sửa kết quả phiên cược',
            style: TextStyle(color: Color(0xFFE2E2E2), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phiên cược đã kết toán với kết quả: ${currentResult.toUpperCase()}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lưu ý: Thay đổi kết quả sẽ tự động đảo trạng thái Won/Lost của toàn bộ đơn cược và hoàn trả/khấu trừ tiền ví của người chơi!',
                style: TextStyle(color: Color(0xFFFFB347), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop('under'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: Colors.black,
              ),
              child: const Text('Sửa thành XỈU'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop('over'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC536D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sửa thành TÀI'),
            ),
          ],
        );
      },
    );

    if (newResult != null && newResult != currentResult) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );
        
        await ref.read(diceSessionServiceProvider).adminOverrideSettleResult(
          sessionId: sessionId,
          newResult: newResult,
        );
        
        Navigator.of(context).pop(); // Dismiss progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã cập nhật lại kết quả phiên thành ${newResult.toUpperCase()} và điều chỉnh ví thành công!'),
            backgroundColor: const Color(0xFF00D4AA),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Dismiss progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFC536D),
          ),
        );
      }
    }
  }

  // Sub-Tab 2: Danh sách đơn cược của tất cả người chơi
  Widget _buildTaiXiuBetsSubTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bets')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có đơn cược nào được đặt.',
              style: TextStyle(color: Color(0xFFE2BEBF)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final betId = doc.id;
            final data = doc.data() as Map<String, dynamic>;
            final userId = data['userId'] as String? ?? 'unknown';
            final sessionNum = data['sessionNumber'] as int? ?? 0;
            final choice = data['choice'] as String? ?? 'over';
            final amount = (data['amount'] as num? ?? 0.0).toDouble();
            final odds = (data['oddsAtTime'] as num? ?? 1.0).toDouble();
            final status = data['status'] as String? ?? 'pending';
            final createdAtVal = data['createdAt'];
            final createdAt = createdAtVal is Timestamp
                ? createdAtVal.toDate()
                : DateTime.now();

            final displayTime = DateFormat('HH:mm:ss dd/MM').format(createdAt);

            Color statusColor = const Color(0xFFFFB347);
            if (status == 'won') {
              statusColor = const Color(0xFF00D4AA);
            } else if (status == 'lost') {
              statusColor = const Color(0xFFFC536D);
            } else if (status == 'push') {
              statusColor = const Color(0xFFA0A0B0);
            }

            return _buildGlassCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Đơn cược: ${choice.toUpperCase()}',
                              style: TextStyle(
                                color: choice == 'over'
                                    ? const Color(0xFFFC536D)
                                    : const Color(0xFF00D4AA),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statusColor.withOpacity(0.4)),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Cược: ${_formatCurrency(amount)} | Odds: x$odds (Thắng nhận: ${_formatCurrency(amount * odds)})',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Phiên cược: #$sessionNum | Người chơi ID: $userId',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                        Text(
                          'Thời gian: $displayTime | ID: $betId',
                          style: const TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_note, color: Color(0xFFFFB2B7)),
                    tooltip: 'Sửa đơn cược',
                    onPressed: () {
                      _showAdminEditBetDialog(context, betId, status);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Sửa trạng thái một đơn cược cụ thể
  Future<void> _showAdminEditBetDialog(BuildContext context, String betId, String currentStatus) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E2020),
          title: const Text(
            'Sửa trạng thái đơn cược',
            style: TextStyle(color: Color(0xFFE2E2E2), fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đơn cược hiện tại có trạng thái: ${currentStatus.toUpperCase()}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              const Text(
                'Lưu ý: Thay đổi trạng thái đơn cược sẽ tự động điều chỉnh số dư ví của tài khoản người chơi tương ứng!',
                style: TextStyle(color: Color(0xFFFFB347), fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop('won'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: Colors.black,
              ),
              child: const Text('Thắng (WON)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop('lost'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFC536D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thua (LOST)'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop('push'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA0A0B0),
                foregroundColor: Colors.black,
              ),
              child: const Text('Hòa (PUSH)'),
            ),
          ],
        );
      },
    );

    if (newStatus != null && newStatus != currentStatus) {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ref.read(diceSessionServiceProvider).adminUpdateBetStatus(
          betId: betId,
          newStatus: newStatus,
        );

        Navigator.of(context).pop(); // Dismiss progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cập nhật trạng thái đơn cược sang ${newStatus.toUpperCase()} thành công!'),
            backgroundColor: const Color(0xFF00D4AA),
          ),
        );
      } catch (e) {
        Navigator.of(context).pop(); // Dismiss progress indicator
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: const Color(0xFFFC536D),
          ),
        );
      }
    }
  }

  // Widget hiển thị cột chỉ số phụ trợ
  Widget _buildMetricCol({
    required String title,
    required String value,
    Color? valColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valColor ?? const Color(0xFFE2E2E2),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSpinWheelTab() {
    return const AdminSpinWheelTab();
  }
}

class AdminSpinWheelTab extends StatefulWidget {
  const AdminSpinWheelTab({super.key});
  @override
  State<AdminSpinWheelTab> createState() => _AdminSpinWheelTabState();
}

class _AdminSpinWheelTabState extends State<AdminSpinWheelTab> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _configData;
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final snap = await FirebaseFirestore.instance.collection('spin_wheel_configs').doc('default_config').get();
      if (snap.exists) {
        setState(() {
          _configData = snap.data();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Chưa có cấu hình Vòng Quay. Vui lòng vào giao diện người chơi để hệ thống tự khởi tạo trước!';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }
  
  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    
    // Validate sum of probabilities
    double totalProb = 0.0;
    for (var seg in _configData!['segments']) {
      totalProb += seg['probability'];
    }
    if ((totalProb - 1.0).abs() > 0.001) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tổng Tỷ lệ trúng (Probability) của tất cả các ô phải đúng bằng 1.0 (100%)!')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('spin_wheel_configs').doc('default_config').update(_configData!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lưu thành công! Vòng quay đã được cập nhật tỷ lệ mới.'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    if (_configData == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cấu Hình Vòng Quay (BETA)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Chú ý: Tổng Tỷ lệ trúng của tất cả các ô phải bằng 1.0 (100%). Ví dụ: 0.4 + 0.35 + 0.15 + 0.08 + 0.015 + 0.005 = 1.0', style: TextStyle(color: Colors.amber)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _configData!['minBet'].toString(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Cược tối thiểu (Xu)', labelStyle: TextStyle(color: Colors.white70)),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _configData!['minBet'] = double.tryParse(val ?? '0') ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: _configData!['maxBet'].toString(),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Cược tối đa (Xu)', labelStyle: TextStyle(color: Colors.white70)),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => _configData!['maxBet'] = double.tryParse(val ?? '0') ?? 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Các Ô Thưởng (Segments)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            ...List.generate((_configData!['segments'] as List).length, (index) {
              final seg = _configData!['segments'][index];
              return Card(
                color: const Color(0xFF2A2D2D),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: seg['label'],
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Nhãn (Label)', labelStyle: TextStyle(color: Colors.white70)),
                          onSaved: (val) => seg['label'] = val,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          initialValue: seg['multiplier'].toString(),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Hệ số x', labelStyle: TextStyle(color: Colors.white70)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => seg['multiplier'] = double.tryParse(val ?? '0') ?? 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          initialValue: seg['probability'].toString(),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(labelText: 'Tỷ lệ (Vd: 0.15 = 15%)', labelStyle: TextStyle(color: Colors.white70)),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onSaved: (val) => seg['probability'] = double.tryParse(val ?? '0') ?? 0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94560), minimumSize: const Size(200, 50)),
              child: const Text('Lưu Thay Đổi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
