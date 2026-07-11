import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminMatchEditScreen extends StatefulWidget {
  const AdminMatchEditScreen({super.key});

  @override
  State<AdminMatchEditScreen> createState() => _AdminMatchEditScreenState();
}

class _AdminMatchEditScreenState extends State<AdminMatchEditScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _searchController = TextEditingController();

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  String _searchQuery = '';
  bool _isProcessing = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _writeAdminLog({
    required String action,
    required String matchId,
    required Map<String, dynamic> details,
  }) async {
    final admin = FirebaseAuth.instance.currentUser;

    await _firestore.collection('admin_logs').add({
      'action': action,
      'adminId': admin?.uid ?? '',
      'adminEmail': admin?.email ?? '',
      'matchId': matchId,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Colors.red.shade700 : const Color(0xFF00A884),
      ),
    );
  }

  Future<void> _showEditOddsDialog({
    required String matchId,
    required Map<String, dynamic> matchData,
  }) async {
    final oddsOverController = TextEditingController(
      text: ((matchData['oddsOver'] as num?)?.toDouble() ?? 1.85).toString(),
    );

    final oddsUnderController = TextEditingController(
      text: ((matchData['oddsUnder'] as num?)?.toDouble() ?? 1.95).toString(),
    );

    final lineController = TextEditingController(
      text:
          ((matchData['overUnderLine'] as num?)?.toDouble() ?? 2.5).toString(),
    );

    final result = await showDialog<Map<String, double>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'Chỉnh sửa tỷ lệ kèo',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${matchData['homeTeam'] ?? 'Đội nhà'}'
                  ' vs '
                  '${matchData['awayTeam'] ?? 'Đội khách'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _NumberField(
                  controller: lineController,
                  label: 'Mốc Tài/Xỉu',
                  icon: Icons.horizontal_rule,
                ),
                const SizedBox(height: 14),
                _NumberField(
                  controller: oddsOverController,
                  label: 'Tỷ lệ Tài',
                  icon: Icons.trending_up,
                ),
                const SizedBox(height: 14),
                _NumberField(
                  controller: oddsUnderController,
                  label: 'Tỷ lệ Xỉu',
                  icon: Icons.trending_down,
                ),
              ],
            ),
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
                final line = double.tryParse(
                  lineController.text.trim().replaceAll(',', '.'),
                );

                final oddsOver = double.tryParse(
                  oddsOverController.text.trim().replaceAll(',', '.'),
                );

                final oddsUnder = double.tryParse(
                  oddsUnderController.text.trim().replaceAll(',', '.'),
                );

                if (line == null || oddsOver == null || oddsUnder == null) {
                  _showMessage(
                    'Vui lòng nhập đúng định dạng số.',
                    isError: true,
                  );
                  return;
                }

                if (line <= 0 || oddsOver <= 1 || oddsUnder <= 1) {
                  _showMessage(
                    'Mốc kèo phải lớn hơn 0 và tỷ lệ phải lớn hơn 1.',
                    isError: true,
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'overUnderLine': line,
                  'oddsOver': oddsOver,
                  'oddsUnder': oddsUnder,
                });
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

    oddsOverController.dispose();
    oddsUnderController.dispose();
    lineController.dispose();

    if (result == null) {
      return;
    }

    await _updateOdds(
      matchId: matchId,
      oldData: matchData,
      newData: result,
    );
  }

  Future<void> _updateOdds({
    required String matchId,
    required Map<String, dynamic> oldData,
    required Map<String, double> newData,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestore.collection('matches').doc(matchId).update({
        'overUnderLine': newData['overUnderLine'],
        'oddsOver': newData['oddsOver'],
        'oddsUnder': newData['oddsUnder'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _writeAdminLog(
        action: 'UPDATE_MATCH_ODDS',
        matchId: matchId,
        details: {
          'homeTeam': oldData['homeTeam'] ?? '',
          'awayTeam': oldData['awayTeam'] ?? '',
          'oldOverUnderLine': oldData['overUnderLine'],
          'oldOddsOver': oldData['oddsOver'],
          'oldOddsUnder': oldData['oddsUnder'],
          'newOverUnderLine': newData['overUnderLine'],
          'newOddsOver': newData['oddsOver'],
          'newOddsUnder': newData['oddsUnder'],
        },
      );

      _showMessage(
        'Đã cập nhật tỷ lệ kèo.',
      );
    } catch (error) {
      _showMessage(
        'Không thể cập nhật tỷ lệ kèo: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _showResultDialog({
    required String matchId,
    required Map<String, dynamic> matchData,
  }) async {
    final scoreHomeController = TextEditingController(
      text: ((matchData['scoreHome'] as num?)?.toInt() ?? 0).toString(),
    );

    final scoreAwayController = TextEditingController(
      text: ((matchData['scoreAway'] as num?)?.toInt() ?? 0).toString(),
    );

    String selectedResult = matchData['result']?.toString() ?? 'over';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF16213E),
              title: const Text(
                'Cập nhật kết quả trận',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${matchData['homeTeam'] ?? 'Đội nhà'}'
                      ' vs '
                      '${matchData['awayTeam'] ?? 'Đội khách'}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFF5F5F5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _NumberField(
                            controller: scoreHomeController,
                            label: 'Tỷ số nhà',
                            icon: Icons.home_outlined,
                            decimal: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NumberField(
                            controller: scoreAwayController,
                            label: 'Tỷ số khách',
                            icon: Icons.flight_takeoff_outlined,
                            decimal: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    DropdownButtonFormField<String>(
                      initialValue: selectedResult,
                      dropdownColor: const Color(0xFF16213E),
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Kết quả Tài/Xỉu',
                        labelStyle: const TextStyle(
                          color: Color(0xFFA0A0B0),
                        ),
                        prefixIcon: const Icon(
                          Icons.fact_check_outlined,
                          color: Color(0xFF00D4AA),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF101522),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'over',
                          child: Text('Tài'),
                        ),
                        DropdownMenuItem(
                          value: 'under',
                          child: Text('Xỉu'),
                        ),
                        DropdownMenuItem(
                          value: 'push',
                          child: Text('Hòa kèo / Hoàn tiền'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }

                        setDialogState(() {
                          selectedResult = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Lưu kết quả sẽ chuyển trạng thái trận sang finished.',
                      style: TextStyle(
                        color: Color(0xFFFFB347),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
                    final scoreHome = int.tryParse(
                      scoreHomeController.text.trim(),
                    );

                    final scoreAway = int.tryParse(
                      scoreAwayController.text.trim(),
                    );

                    if (scoreHome == null ||
                        scoreAway == null ||
                        scoreHome < 0 ||
                        scoreAway < 0) {
                      _showMessage(
                        'Tỷ số phải là số nguyên không âm.',
                        isError: true,
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, {
                      'scoreHome': scoreHome,
                      'scoreAway': scoreAway,
                      'result': selectedResult,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE94560),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Chốt kết quả',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    scoreHomeController.dispose();
    scoreAwayController.dispose();

    if (result == null) {
      return;
    }

    await _updateMatchResult(
      matchId: matchId,
      oldData: matchData,
      newData: result,
    );
  }

  Future<void> _updateMatchResult({
    required String matchId,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
  }) async {
    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestore.collection('matches').doc(matchId).update({
        'scoreHome': newData['scoreHome'],
        'scoreAway': newData['scoreAway'],
        'result': newData['result'],
        'status': 'finished',
        'isBettingLocked': true,
        'updatedAt': FieldValue.serverTimestamp(),
        'settledAt': FieldValue.serverTimestamp(),
      });

      await _writeAdminLog(
        action: 'ADMIN_OVERRIDE_MATCH_RESULT',
        matchId: matchId,
        details: {
          'homeTeam': oldData['homeTeam'] ?? '',
          'awayTeam': oldData['awayTeam'] ?? '',
          'oldScoreHome': oldData['scoreHome'],
          'oldScoreAway': oldData['scoreAway'],
          'oldResult': oldData['result'],
          'newScoreHome': newData['scoreHome'],
          'newScoreAway': newData['scoreAway'],
          'newResult': newData['result'],
          'newStatus': 'finished',
        },
      );

      _showMessage(
        'Đã cập nhật kết quả trận đấu.',
      );
    } catch (error) {
      _showMessage(
        'Không thể cập nhật kết quả: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _toggleBettingLock({
    required String matchId,
    required Map<String, dynamic> matchData,
  }) async {
    final currentlyLocked = matchData['isBettingLocked'] as bool? ?? false;

    final nextLocked = !currentlyLocked;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16213E),
          title: Text(
            nextLocked ? 'Khóa cược trận này?' : 'Mở cược trận này?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            nextLocked
                ? 'Người chơi sẽ không thể tạo thêm lệnh cược cho trận này.'
                : 'Người chơi sẽ có thể tiếp tục đặt cược cho trận này.',
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
                backgroundColor: nextLocked
                    ? const Color(0xFFE94560)
                    : const Color(0xFF00D4AA),
                foregroundColor:
                    nextLocked ? Colors.white : const Color(0xFF101522),
              ),
              child: Text(
                nextLocked ? 'Khóa cược' : 'Mở cược',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    if (_isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestore.collection('matches').doc(matchId).update({
        'isBettingLocked': nextLocked,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _writeAdminLog(
        action: nextLocked ? 'LOCK_MATCH_BETTING' : 'UNLOCK_MATCH_BETTING',
        matchId: matchId,
        details: {
          'homeTeam': matchData['homeTeam'] ?? '',
          'awayTeam': matchData['awayTeam'] ?? '',
          'isBettingLocked': nextLocked,
        },
      );

      _showMessage(
        nextLocked ? 'Đã khóa cược trận đấu.' : 'Đã mở cược trận đấu.',
      );
    } catch (error) {
      _showMessage(
        'Không thể cập nhật trạng thái cược: $error',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _filterMatches(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered = docs.where((document) {
      if (_searchQuery.isEmpty) {
        return true;
      }

      final data = document.data();

      final home = data['homeTeam']?.toString().toLowerCase() ?? '';

      final away = data['awayTeam']?.toString().toLowerCase() ?? '';

      final status = data['status']?.toString().toLowerCase() ?? '';

      return home.contains(_searchQuery) ||
          away.contains(_searchQuery) ||
          status.contains(_searchQuery) ||
          document.id.toLowerCase().contains(_searchQuery);
    }).toList();

    filtered.sort((first, second) {
      final firstTimestamp = first.data()['utcDate'] as Timestamp?;

      final secondTimestamp = second.data()['utcDate'] as Timestamp?;

      return (secondTimestamp?.millisecondsSinceEpoch ?? 0).compareTo(
        firstTimestamp?.millisecondsSinceEpoch ?? 0,
      );
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101522),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        title: const Text(
          'Quản lý trận đấu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.only(right: 18),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF00D4AA),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _firestore.collection('matches').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'Không thể tải trận đấu:\n'
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFE94560),
                        ),
                      ),
                    ),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00D4AA),
                    ),
                  );
                }

                final matches = _filterMatches(
                  snapshot.data!.docs,
                );

                if (matches.isEmpty) {
                  return const Center(
                    child: Text(
                      'Không tìm thấy trận đấu',
                      style: TextStyle(
                        color: Color(0xFFA0A0B0),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    24,
                  ),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final match = matches[index];

                    return _buildMatchCard(
                      matchId: match.id,
                      data: match.data(),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0F3460),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quản trị trận đấu',
            style: TextStyle(
              color: Color(0xFFF5F5F5),
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Sửa tỷ lệ kèo, chốt kết quả và khóa hoặc mở cược.',
            style: TextStyle(
              color: Color(0xFFA0A0B0),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        decoration: InputDecoration(
          hintText: 'Tìm đội, trạng thái hoặc mã trận',
          hintStyle: const TextStyle(
            color: Color(0xFF8B91A7),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00D4AA),
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                    color: Colors.white70,
                  ),
                ),
          filled: true,
          fillColor: const Color(0xFF16213E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildMatchCard({
    required String matchId,
    required Map<String, dynamic> data,
  }) {
    final homeTeam = data['homeTeam']?.toString() ?? 'Đội nhà';

    final awayTeam = data['awayTeam']?.toString() ?? 'Đội khách';

    final status = data['status']?.toString() ?? 'scheduled';

    final result = data['result']?.toString();

    final scoreHome = (data['scoreHome'] as num?)?.toInt() ?? 0;

    final scoreAway = (data['scoreAway'] as num?)?.toInt() ?? 0;

    final oddsOver = (data['oddsOver'] as num?)?.toDouble() ?? 1.85;

    final oddsUnder = (data['oddsUnder'] as num?)?.toDouble() ?? 1.95;

    final line = (data['overUnderLine'] as num?)?.toDouble() ?? 2.5;

    final isBettingLocked = data['isBettingLocked'] as bool? ?? false;

    final utcDate = data['utcDate'] as Timestamp?;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isBettingLocked
              ? const Color(0xFFE94560)
              : const Color(0xFF0F3460),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  utcDate == null
                      ? 'Chưa có lịch'
                      : _dateFormatter.format(
                          utcDate.toDate().toLocal(),
                        ),
                  style: const TextStyle(
                    color: Color(0xFFA0A0B0),
                    fontSize: 12,
                  ),
                ),
              ),
              _StatusBadge(
                status: status,
                isLocked: isBettingLocked,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  homeTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    '$scoreHome - $scoreAway',
                    style: const TextStyle(
                      color: Color(0xFFFFB347),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    result == null ? 'VS' : _resultLabel(result),
                    style: const TextStyle(
                      color: Color(0xFFA0A0B0),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Text(
                  awayTeam,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF5F5F5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ValueBox(
                  label: 'Mốc',
                  value: line.toStringAsFixed(1),
                  color: const Color(0xFFFFB347),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueBox(
                  label: 'Tài',
                  value: oddsOver.toStringAsFixed(2),
                  color: const Color(0xFF00D4AA),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueBox(
                  label: 'Xỉu',
                  value: oddsUnder.toStringAsFixed(2),
                  color: const Color(0xFFE94560),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          _showEditOddsDialog(
                            matchId: matchId,
                            matchData: data,
                          );
                        },
                  icon: const Icon(Icons.tune),
                  label: const Text('Sửa kèo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF00D4AA),
                    side: const BorderSide(
                      color: Color(0xFF00D4AA),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isProcessing
                      ? null
                      : () {
                          _showResultDialog(
                            matchId: matchId,
                            matchData: data,
                          );
                        },
                  icon: const Icon(
                    Icons.fact_check_outlined,
                  ),
                  label: const Text('Kết quả'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFB347),
                    side: const BorderSide(
                      color: Color(0xFFFFB347),
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
              onPressed: _isProcessing
                  ? null
                  : () {
                      _toggleBettingLock(
                        matchId: matchId,
                        matchData: data,
                      );
                    },
              icon: Icon(
                isBettingLocked ? Icons.lock_open_outlined : Icons.lock_outline,
              ),
              label: Text(
                isBettingLocked ? 'MỞ CƯỢC TRẬN' : 'KHÓA CƯỢC TRẬN',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isBettingLocked
                    ? const Color(0xFF00D4AA)
                    : const Color(0xFFE94560),
                foregroundColor:
                    isBettingLocked ? const Color(0xFF101522) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _resultLabel(String result) {
    switch (result) {
      case 'over':
        return 'KẾT QUẢ: TÀI';
      case 'under':
        return 'KẾT QUẢ: XỈU';
      case 'push':
        return 'KẾT QUẢ: HÒA KÈO';
      default:
        return result.toUpperCase();
    }
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool decimal;

  const _NumberField({
    required this.controller,
    required this.label,
    required this.icon,
    this.decimal = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: decimal,
      ),
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color(0xFFA0A0B0),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF00D4AA),
        ),
        filled: true,
        fillColor: const Color(0xFF101522),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ValueBox({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101522),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA0A0B0),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isLocked;

  const _StatusBadge({
    required this.status,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    if (isLocked) {
      return _buildBadge(
        label: 'ĐÃ KHÓA CƯỢC',
        color: const Color(0xFFE94560),
        icon: Icons.lock,
      );
    }

    switch (status) {
      case 'inPlay':
        return _buildBadge(
          label: 'ĐANG ĐÁ',
          color: const Color(0xFFE94560),
          icon: Icons.sports_soccer,
        );
      case 'finished':
        return _buildBadge(
          label: 'KẾT THÚC',
          color: const Color(0xFF00D4AA),
          icon: Icons.check_circle,
        );
      default:
        return _buildBadge(
          label: 'SẮP DIỄN RA',
          color: const Color(0xFFFFB347),
          icon: Icons.schedule,
        );
    }
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
