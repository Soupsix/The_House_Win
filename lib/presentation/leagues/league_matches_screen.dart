import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../application/leagues/league_provider.dart';
import '../../application/matches/match_provider.dart';
import '../../domain/models/league_model.dart';
import '../../domain/models/match_model.dart';
import '../../domain/enums/match_status.dart';
import '../matches/match_detail_screen.dart';

class LeagueMatchesScreen extends ConsumerStatefulWidget {
  final LeagueModel league;
  const LeagueMatchesScreen({super.key, required this.league});

  @override
  ConsumerState<LeagueMatchesScreen> createState() =>
      _LeagueMatchesScreenState();
}

class _LeagueMatchesScreenState extends ConsumerState<LeagueMatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leagueState = ref.watch(leagueProvider);
    final matches = leagueState.leagueMatches;

    final live =
        matches.where((m) => m.status == MatchStatus.inPlay).toList();
    final scheduled =
        matches.where((m) => m.status == MatchStatus.scheduled).toList();
    final finished =
        matches.where((m) => m.status == MatchStatus.finished).toList();

    final initials = _getInitials(widget.league.name);
    final gradColor = _gradientForName(widget.league.name);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (leagueState.isLoadingMatches)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFE94560)),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFFE94560)),
              onPressed: () =>
                  ref.read(leagueProvider.notifier).refreshLeagueMatches(),
            ),
        ],
        // Header nội dung: logo + tên + quốc gia
        title: Row(
          children: [
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [gradColor, gradColor.withValues(alpha: 0.6)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: widget.league.logo != null &&
                      widget.league.logo!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.league.logo!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Text(initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
            ),
            const SizedBox(width: 12),
            // Tên + quốc gia
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.league.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.public,
                          size: 12, color: Color(0xFFA0A0B0)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          widget.league.country.isNotEmpty
                              ? widget.league.country
                              : 'Quốc tế',
                          style: const TextStyle(
                              color: Color(0xFFA0A0B0), fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (matches.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE94560)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${matches.length} trận',
                            style: const TextStyle(
                                color: Color(0xFFE94560),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        // TabBar nằm riêng phía dưới, không bị đè
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFE94560),
          labelColor: const Color(0xFFE94560),
          unselectedLabelColor: const Color(0xFFA0A0B0),
          tabs: [
            _buildTab('TRỰC TIẾP', live.length, const Color(0xFFE94560)),
            _buildTab('SẮP TỚI', scheduled.length, const Color(0xFF00D4AA)),
            _buildTab('KẾT QUẢ', finished.length, const Color(0xFFA0A0B0)),
          ],
        ),
      ),
      body: leagueState.isLoadingMatches
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFE94560)),
                  SizedBox(height: 16),
                  Text('Đang tải lịch thi đấu...',
                      style: TextStyle(color: Color(0xFFA0A0B0))),
                ],
              ),
            )
          : leagueState.errorMatches != null && matches.isEmpty
              ? _buildError(leagueState.errorMatches!)
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMatchList(live, MatchStatus.inPlay),
                    _buildMatchList(scheduled, MatchStatus.scheduled),
                    _buildMatchList(finished, MatchStatus.finished),
                  ],
                ),
    );
  }

  Tab _buildTab(String label, int count, Color badgeColor) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          if (count > 0) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: label == 'SẮP TỚI' ? Colors.black : Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMatchList(List<MatchModel> matches, MatchStatus status) {
    if (matches.isEmpty) {
      final icon = status == MatchStatus.inPlay
          ? Icons.sports_soccer
          : status == MatchStatus.scheduled
              ? Icons.schedule
              : Icons.check_circle_outline;
      final msg = status == MatchStatus.inPlay
          ? 'Không có trận đang diễn ra'
          : status == MatchStatus.scheduled
              ? 'Không có trận sắp tới'
              : 'Không có kết quả';
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: const Color(0xFF3A3A5C)),
            const SizedBox(height: 12),
            Text(msg,
                style:
                    const TextStyle(color: Color(0xFFA0A0B0), fontSize: 15)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: matches.length,
      itemBuilder: (context, i) => _MatchCard(match: matches[i], status: status),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Color(0xFFE94560), size: 56),
            const SizedBox(height: 16),
            const Text('Không thể tải dữ liệu',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(leagueProvider.notifier).refreshLeagueMatches(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _gradientForName(String name) {
    const colors = [
      Color(0xFF1565C0),
      Color(0xFF6A1B9A),
      Color(0xFF2E7D32),
      Color(0xFFBF360C),
      Color(0xFF00695C),
      Color(0xFF37474F),
    ];
    return colors[name.codeUnitAt(0) % colors.length];
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}

// ---- Match Card trong giải đấu ----
class _MatchCard extends ConsumerWidget {
  final MatchModel match;
  final MatchStatus status;
  const _MatchCard({required this.match, required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('HH:mm - dd/MM/yyyy');
    final isLive = status == MatchStatus.inPlay;
    final isFinished = status == MatchStatus.finished;

    return GestureDetector(
      onTap: () {
        if (isFinished) return;
        ref.read(matchProvider.notifier).selectMatch(match);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const MatchDetailScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isLive
                ? const Color(0xFFE94560).withValues(alpha: 0.5)
                : const Color(0xFF0F3460),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 3)),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            // Header: thời gian + trạng thái
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateFormat.format(match.utcDate.toLocal()),
                  style: const TextStyle(
                      color: Color(0xFFA0A0B0), fontSize: 12),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLive
                        ? const Color(0xFFE94560).withValues(alpha: 0.15)
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
            const SizedBox(height: 14),
            // Teams + score
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _teamLogo(match.homeTeamLogo),
                      const SizedBox(height: 6),
                      Text(
                        match.homeTeam,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Text(
                        (isLive || isFinished)
                            ? '${match.scoreHome} - ${match.scoreAway}'
                            : 'VS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isFinished
                              ? Colors.white
                              : isLive
                                  ? const Color(0xFFFFB347)
                                  : Colors.white70,
                        ),
                      ),
                      if (!isFinished) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Mốc ${match.overUnderLine}',
                          style: const TextStyle(
                              color: Color(0xFF00D4AA), fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _teamLogo(match.awayTeamLogo),
                      const SizedBox(height: 6),
                      Text(
                        match.awayTeam,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Odds (chỉ hiện khi không phải finished)
            if (!isFinished) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3460).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _oddsChip('Tài', 'x${match.oddsOver}',
                        const Color(0xFFE94560)),
                    Container(
                        width: 1, height: 20, color: const Color(0xFF3A3A5C)),
                    _oddsChip('Xỉu', 'x${match.oddsUnder}',
                        const Color(0xFF00D4AA)),
                    Container(
                        width: 1, height: 20, color: const Color(0xFF3A3A5C)),
                    _oddsChip('Hoà', 'x${match.oddsDraw}',
                        const Color(0xFFFFB347)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _teamLogo(String? url) {
    if (url != null && url.isNotEmpty) {
      return CircleAvatar(
        radius: 22,
        backgroundColor: const Color(0xFF0F3460),
        child: ClipOval(
          child: Image.network(
            url,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.shield, color: Colors.white70, size: 22),
          ),
        ),
      );
    }
    return const CircleAvatar(
      radius: 22,
      backgroundColor: Color(0xFF0F3460),
      child: Icon(Icons.shield, color: Colors.white70, size: 22),
    );
  }

  Widget _oddsChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style:
                const TextStyle(color: Color(0xFFA0A0B0), fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}
