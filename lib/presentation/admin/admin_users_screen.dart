import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/admin/admin_provider.dart';
import '../../domain/models/user_model.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();

  final NumberFormat _moneyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VNĐ',
    decimalDigits: 0,
  );

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    ref.listen(adminProvider, (previous, next) {
      final previousError = previous?.errorMessage;
      final previousSuccess = previous?.successMessage;

      if (next.errorMessage != null && next.errorMessage != previousError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }

      if (next.successMessage != null &&
          next.successMessage != previousSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: const Color(0xFF00A884),
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quản lý người chơi',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tải lại dữ liệu',
            onPressed: () {
              ref.read(adminProvider.notifier).initialize();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummary(
            totalUsers: adminState.users.length,
            totalAdmins: adminState.users.where((user) => user.isAdmin).length,
            totalBalance: adminState.userBalances.values.fold(
              0.0,
              (sum, balance) => sum + balance,
            ),
          ),
          _buildSearchBox(),
          Expanded(
            child: _buildUsersList(
              users: adminState.filteredUsers,
              balances: adminState.userBalances,
              isLoading: adminState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary({
    required int totalUsers,
    required int totalAdmins,
    required double totalBalance,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0F3460),
        ),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.groups_rounded,
                color: Color(0xFF00D4AA),
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'Tổng quan người dùng',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Người dùng',
                  value: '$totalUsers',
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryItem(
                  label: 'Admin',
                  value: '$totalAdmins',
                  icon: Icons.admin_panel_settings_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _SummaryItem(
            label: 'Tổng tiền trong hệ thống',
            value: _moneyFormatter.format(totalBalance),
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
        ),
        onChanged: (value) {
          ref.read(adminProvider.notifier).setSearchQuery(value.trim());
        },
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, email hoặc số điện thoại',
          hintStyle: const TextStyle(
            color: Color(0xFF8B91A7),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00D4AA),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(adminProvider.notifier).setSearchQuery('');

                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF16213E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF0F3460),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: Color(0xFF00D4AA),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsersList({
    required List<UserModel> users,
    required Map<String, double> balances,
    required bool isLoading,
  }) {
    if (isLoading && users.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00D4AA),
        ),
      );
    }

    if (users.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.person_search_outlined,
                size: 70,
                color: Color(0xFF6F7690),
              ),
              SizedBox(height: 14),
              Text(
                'Không tìm thấy người dùng',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF00D4AA),
      onRefresh: () async {
        ref.read(adminProvider.notifier).initialize();
        await Future<void>.delayed(
          const Duration(milliseconds: 700),
        );
      },
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: users.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final user = users[index];
          final balance = balances[user.uid] ?? 0;

          return _buildUserCard(
            user: user,
            balance: balance,
          );
        },
      ),
    );
  }

  Widget _buildUserCard({
    required UserModel user,
    required double balance,
  }) {
    final displayName = user.displayName.trim().isEmpty
        ? 'Chưa đặt tên'
        : user.displayName.trim();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color:
              user.isAdmin ? const Color(0xFFFFB347) : const Color(0xFF0F3460),
        ),
      ),
      child: ExpansionTile(
        iconColor: const Color(0xFF00D4AA),
        collapsedIconColor: const Color(0xFF8B91A7),
        tilePadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          18,
        ),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor:
              user.isAdmin ? const Color(0xFFFFB347) : const Color(0xFF0F3460),
          child: Icon(
            user.isAdmin ? Icons.admin_panel_settings : Icons.person,
            color: user.isAdmin ? const Color(0xFF1A1A2E) : Colors.white,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF5F5F5),
                ),
              ),
            ),
            if (user.isAdmin)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB347),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMIN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            _moneyFormatter.format(balance),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4AA),
            ),
          ),
        ),
        children: [
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.phone_outlined,
            label: 'Số điện thoại',
            value: user.phoneNumber.trim().isEmpty
                ? 'Chưa cập nhật'
                : user.phoneNumber,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Ngày tạo',
            value: _dateFormatter.format(user.createdAt),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.fingerprint,
            label: 'UID',
            value: user.uid,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showEditBalanceDialog(
                      user: user,
                      currentBalance: balance,
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Sửa số dư'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D4AA),
                    side: const BorderSide(
                      color: Color(0xFF00D4AA),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showResetWalletDialog(user);
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: const Text('Reset ví'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFB347),
                    side: const BorderSide(
                      color: Color(0xFFFFB347),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _showToggleAdminDialog(user);
              },
              icon: Icon(
                user.isAdmin
                    ? Icons.remove_moderator_outlined
                    : Icons.admin_panel_settings_outlined,
              ),
              label: Text(
                user.isAdmin ? 'Thu hồi quyền Admin' : 'Cấp quyền Admin',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isAdmin
                    ? const Color(0xFFE94560)
                    : const Color(0xFFFFB347),
                foregroundColor:
                    user.isAdmin ? Colors.white : const Color(0xFF1A1A2E),
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditBalanceDialog({
    required UserModel user,
    required double currentBalance,
  }) async {
    final controller = TextEditingController(
      text: currentBalance.toStringAsFixed(0),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'Chỉnh sửa số dư',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName.trim().isEmpty ? user.email : user.displayName,
                style: const TextStyle(
                  color: Color(0xFFA0A0B0),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  labelText: 'Số dư mới',
                  labelStyle: const TextStyle(
                    color: Color(0xFFA0A0B0),
                  ),
                  suffixText: 'VNĐ',
                  suffixStyle: const TextStyle(
                    color: Color(0xFF00D4AA),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF101522),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final rawValue = controller.text
                    .replaceAll(',', '')
                    .replaceAll(' ', '')
                    .trim();

                final value = double.tryParse(rawValue);

                if (value == null || value < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Số dư phải là số lớn hơn hoặc bằng 0.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4AA),
                foregroundColor: const Color(0xFF101522),
              ),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result == null) {
      return;
    }

    await ref.read(adminProvider.notifier).adminEditBalance(
          user.uid,
          result,
        );
  }

  Future<void> _showResetWalletDialog(
    UserModel user,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'Reset ví người chơi?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Ví của ${user.displayName.isEmpty ? user.email : user.displayName} '
            'sẽ được khôi phục về số dư mặc định. '
            'Lịch sử giao dịch ví có thể bị xóa.',
            style: const TextStyle(
              color: Color(0xFFA0A0B0),
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
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reset ví'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(adminProvider.notifier).resetUserWallet(user.uid);
  }

  Future<void> _showToggleAdminDialog(
    UserModel user,
  ) async {
    final nextStatus = !user.isAdmin;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            nextStatus ? 'Cấp quyền Admin?' : 'Thu hồi quyền Admin?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            nextStatus
                ? '${user.displayName.isEmpty ? user.email : user.displayName} '
                    'sẽ có quyền truy cập khu vực quản trị.'
                : '${user.displayName.isEmpty ? user.email : user.displayName} '
                    'sẽ không còn quyền truy cập khu vực quản trị.',
            style: const TextStyle(
              color: Color(0xFFA0A0B0),
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
                backgroundColor: nextStatus
                    ? const Color(0xFFFFB347)
                    : const Color(0xFFE94560),
                foregroundColor:
                    nextStatus ? const Color(0xFF101522) : Colors.white,
              ),
              child: Text(
                nextStatus ? 'Cấp quyền' : 'Thu hồi',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await ref.read(adminProvider.notifier).toggleAdminStatus(
          user.uid,
          nextStatus,
        );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF101522),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D4AA),
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8B91A7),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF5F5F5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 19,
          color: const Color(0xFF8B91A7),
        ),
        const SizedBox(width: 9),
        SizedBox(
          width: 92,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8B91A7),
            ),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFF5F5F5),
            ),
          ),
        ),
      ],
    );
  }
}
