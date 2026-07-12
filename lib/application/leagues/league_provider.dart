import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'league_state.dart';
import 'league_notifier.dart';
import '../matches/match_provider.dart'; // reuse footballApiClientProvider

final leagueProvider = StateNotifierProvider<LeagueNotifier, LeagueState>(
  (ref) => LeagueNotifier(ref.read(footballApiClientProvider)),
);

/// Provider tiện lợi
final leaguesListProvider = Provider<LeagueState>(
  (ref) => ref.watch(leagueProvider),
);
