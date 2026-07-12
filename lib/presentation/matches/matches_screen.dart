import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/matches/match_provider.dart';
import '../../domain/models/match_model.dart';
import '../../domain/enums/match_status.dart';
import 'match_detail_screen.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to "SẮP DIỄN RA" tab (index 1)
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

    Future.microtask(() async {
      // Load from Firestore first (gets simulated matches)
      await ref.read(matchProvider.notifier).loadFromCache();
      // Then sync from API (gets real match data)
      ref.read(matchProvider.notifier).syncFromApi();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liveMatches = ref.watch(liveMatchesProvider);
    final scheduledMatches = ref.watch(scheduledMatchesProvider);
    final finishedMatches = ref.watch(finishedMatchesProvider);
    final matchState = ref.watch(matchProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Trận đấu',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Color(0xFFF5F5F5),
          ),
        ),
        actions: [
          IconButton(
            icon: matchState.isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE94560),
                    ),
                  )
                : const Icon(Icons.sync, color: Color(0xFFE94560)),
            onPressed: matchState.isRefreshing
                ? null
                : () async {
                    await ref.read(matchProvider.notifier).loadFromCache();
                    ref.read(matchProvider.notifier).syncFromApi();
                  },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE94560),
          labelColor: const Color(0xFFE94560),
          unselectedLabelColor: const Color(0xFFA0A0B0),
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('TRỰC TIẾP'),
                  if (liveMatches.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE94560),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${liveMatches.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('SẮP TỚI'),
                  if (scheduledMatches.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4AA),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${scheduledMatches.length}',
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('KẾT QUẢ'),
                  if (finishedMatches.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA0A0B0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${finishedMatches.length}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMatchList(liveMatches, status: MatchStatus.inPlay),
          _buildMatchList(scheduledMatches, status: MatchStatus.scheduled),
          _buildMatchList(finishedMatches, status: MatchStatus.finished),
        ],
      ),
    );
  }

  Widget _buildMatchList(List<MatchModel> matches,
      {required MatchStatus status}) {
    if (matches.isEmpty) {
      final message = switch (status) {
        MatchStatus.inPlay => 'Không có trận đấu nào đang diễn ra.',
        MatchStatus.scheduled => 'Không có trận đấu nào sắp tới.',
        MatchStatus.finished => 'Không có kết quả trận đấu nào.',
        _ => 'Không có dữ liệu.',
      };
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              status == MatchStatus.inPlay
                  ? Icons.sports_soccer
                  : status == MatchStatus.scheduled
                      ? Icons.schedule
                      : Icons.check_circle_outline,
              size: 48,
              color: const Color(0xFF3A3A5C),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style:
                  const TextStyle(color: Color(0xFFA0A0B0), fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return _buildMatchCard(context, match, status: status);
      },
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchModel match,
      {required MatchStatus status}) {
    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    final isLive = status == MatchStatus.inPlay;
    final isFinished = status == MatchStatus.finished;

    return GestureDetector(
      onTap: () {
        if (isFinished) return; // Can't bet on finished matches
        ref.read(matchProvider.notifier).selectMatch(match);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MatchDetailScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive
                ? const Color(0xFFE94560).withValues(alpha: 0.5)
                : const Color(0xFF0F3460),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(match.utcDate),
                  style: const TextStyle(
                    color: Color(0xFFA0A0B0),
                    fontSize: 12,
                  ),
                ),
                Row(
                  children: [


                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLive
                            ? const Color(0xFFE94560).withValues(alpha: 0.2)
                            : isFinished
                                ? const Color(0xFF28DFB5).withValues(alpha: 0.1)
                                : const Color(0xFF0F3460),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLive
                            ? '🔴 LIVE'
                            : isFinished
                                ? 'KẾT THÚC'
                                : 'SẮP TỚI',
                        style: TextStyle(
                          color: isLive
                              ? const Color(0xFFE94560)
                              : isFinished
                                  ? const Color(0xFF28DFB5)
                                  : const Color(0xFF00D4AA),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF0F3460),
                        child: Icon(Icons.shield, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.homeTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Text(
                        (isLive || isFinished)
                            ? '${match.scoreHome} - ${match.scoreAway}'
                            : 'vs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isFinished
                              ? Colors.white
                              : isLive
                                  ? const Color(0xFFFFB347)
                                  : Colors.white,
                        ),
                      ),
                      if (!isFinished) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mốc: ${match.overUnderLine} bàn',
                          style: const TextStyle(
                              color: Color(0xFF00D4AA), fontSize: 11),
                        ),
                      ],
                      if (isFinished && match.result != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF28DFB5).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            match.result!.name.toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xFF28DFB5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF0F3460),
                        child: Icon(Icons.shield, color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        match.awayTeam,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isFinished) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOddsChip(
                      'Tài (Over)', 'x${match.oddsOver}', const Color(0xFFE94560)),
                  _buildOddsChip(
                      'Mốc', '${match.overUnderLine}', const Color(0xFFA0A0B0)),
                  _buildOddsChip(
                      'Xỉu (Under)', 'x${match.oddsUnder}', const Color(0xFF00D4AA)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOddsChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
              color: color, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
