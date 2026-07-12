import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/leagues/league_provider.dart';
import '../../domain/models/league_model.dart';
import 'league_matches_screen.dart';

class LeaguesScreen extends ConsumerStatefulWidget {
  const LeaguesScreen({super.key});

  @override
  ConsumerState<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends ConsumerState<LeaguesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    Future.microtask(() => ref.read(leagueProvider.notifier).fetchLeagues());
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leagueState = ref.watch(leagueProvider);
    final filteredLeagues = _searchQuery.isEmpty
        ? leagueState.leagues
        : leagueState.leagues
            .where((l) =>
                l.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                l.country.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: CustomScrollView(
        slivers: [
          // ----- SliverAppBar đẹp -----
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF16213E),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE94560).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -30,
                      left: 60,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00D4AA).withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 55, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.emoji_events,
                                  color: Color(0xFFFFD700), size: 28),
                              SizedBox(width: 10),
                              Text(
                                'Giải đấu',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Khám phá ${leagueState.leagues.length} giải đấu trên thế giới',
                            style: const TextStyle(
                              color: Color(0xFFA0A0B0),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (leagueState.isLoadingLeagues)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFE94560),
                    ),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh, color: Color(0xFFE94560)),
                  onPressed: () =>
                      ref.read(leagueProvider.notifier).fetchLeagues(),
                ),
            ],
          ),

          // ----- Search bar -----
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm giải đấu, quốc gia...',
                  hintStyle: const TextStyle(color: Color(0xFF606080)),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF606080)),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: Color(0xFF606080)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
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
                    borderSide:
                        const BorderSide(color: Color(0xFF0F3460), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFFE94560), width: 1.5),
                  ),
                ),
              ),
            ),
          ),

          // ----- Content -----
          if (leagueState.isLoadingLeagues)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFFE94560)),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách giải đấu...',
                      style: TextStyle(color: Color(0xFFA0A0B0)),
                    ),
                  ],
                ),
              ),
            )
          else if (leagueState.errorLeagues != null &&
              leagueState.leagues.isEmpty)
            SliverFillRemaining(
              child: _buildError(leagueState.errorLeagues!),
            )
          else if (filteredLeagues.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off,
                        color: Color(0xFF3A3A5C), size: 64),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isNotEmpty
                          ? 'Không tìm thấy giải đấu\n"$_searchQuery"'
                          : 'Chưa có giải đấu nào',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Color(0xFFA0A0B0), fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final league = filteredLeagues[index];
                    return AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        final delay = (index * 0.06).clamp(0.0, 0.8);
                        final anim = CurvedAnimation(
                          parent: _animController,
                          curve: Interval(delay, (delay + 0.4).clamp(0, 1),
                              curve: Curves.easeOut),
                        );
                        return FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        );
                      },
                      child: _LeagueCard(league: league),
                    );
                  },
                  childCount: filteredLeagues.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: Color(0xFFE94560), size: 64),
            const SizedBox(height: 16),
            Text(
              'Không thể tải dữ liệu',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFA0A0B0), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(leagueProvider.notifier).fetchLeagues(),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94560),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---- LeagueCard Widget ----
class _LeagueCard extends ConsumerWidget {
  final LeagueModel league;
  const _LeagueCard({required this.league});

  static const List<List<Color>> _gradients = [
    [Color(0xFF1a237e), Color(0xFF0F3460)],
    [Color(0xFF4a0e0e), Color(0xFF7B1FA2)],
    [Color(0xFF0a3622), Color(0xFF1B5E20)],
    [Color(0xFF3e2723), Color(0xFFBF360C)],
    [Color(0xFF1a237e), Color(0xFF006064)],
    [Color(0xFF37474F), Color(0xFF263238)],
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradIdx = league.name.codeUnitAt(0) % _gradients.length;
    final grad = _gradients[gradIdx];
    final initials = _getInitials(league.name);

    return GestureDetector(
      onTap: () {
        ref.read(leagueProvider.notifier).selectLeague(league);
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, anim, __) => LeagueMatchesScreen(league: league),
            transitionsBuilder: (_, anim, __, child) => SlideTransition(
              position: Tween<Offset>(
                      begin: const Offset(1, 0), end: Offset.zero)
                  .animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
              child: child,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [grad[0].withValues(alpha: 0.6), const Color(0xFF16213E)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF0F3460).withValues(alpha: 0.8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            splashColor: const Color(0xFFE94560).withValues(alpha: 0.1),
            onTap: () {
              ref.read(leagueProvider.notifier).selectLeague(league);
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, anim, __) =>
                      LeagueMatchesScreen(league: league),
                  transitionsBuilder: (_, anim, __, child) => SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(1, 0), end: Offset.zero)
                        .animate(CurvedAnimation(
                            parent: anim, curve: Curves.easeInOut)),
                    child: child,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Logo hoặc avatar initials
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: grad),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: grad[0].withValues(alpha: 0.4),
                            blurRadius: 8)
                      ],
                    ),
                    child: league.logo != null && league.logo!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              league.logo!,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Tên giải + quốc gia
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          league.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (league.countryFlag != null &&
                                league.countryFlag!.isNotEmpty) ...[
                              Image.network(
                                league.countryFlag!,
                                width: 16,
                                height: 12,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.flag,
                                    size: 14,
                                    color: Color(0xFFA0A0B0)),
                              ),
                              const SizedBox(width: 6),
                            ] else ...[
                              const Icon(Icons.public,
                                  size: 14, color: Color(0xFFA0A0B0)),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                league.country.isNotEmpty
                                    ? league.country
                                    : 'Quốc tế',
                                style: const TextStyle(
                                    color: Color(0xFFA0A0B0), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (league.totalTeams != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F3460),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${league.totalTeams} đội',
                                  style: const TextStyle(
                                      color: Color(0xFF00D4AA),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (league.season != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Mùa ${league.season}',
                            style: const TextStyle(
                                color: Color(0xFF606080), fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right,
                      color: Color(0xFF606080), size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, 1).toUpperCase();
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
