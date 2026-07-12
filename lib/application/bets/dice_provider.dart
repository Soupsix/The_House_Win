import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/game_session_config.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/enums/session_status.dart';
import '../../data/firebase/betting_session_service.dart';
import '../../core/services/session_timer_service.dart';
import '../wallet/wallet_provider.dart';
import '../matches/match_provider.dart'; // Để lấy databaseHelperProvider
import 'dice_notifier.dart';
import 'dice_state.dart';
import 'bet_state.dart';

// Provider cho BettingSessionService của Dice (dùng collections mặc định 'betting_sessions' và 'bets')
final diceSessionServiceProvider = Provider<BettingSessionService>(
  (ref) => BettingSessionService(
    sessionCollection: 'betting_sessions',
    betCollection: 'bets',
  ),
);

// Provider cho SessionTimerService của Dice
final diceTimerServiceProvider = Provider<SessionTimerService>(
  (ref) => SessionTimerService(
    ref.read(diceSessionServiceProvider),
    GameSessionConfigs.dice,
  ),
);

// Provider cho DiceNotifier
final diceProvider = StateNotifierProvider<DiceNotifier, DiceState>(
  (ref) {
    final notifier = DiceNotifier(
      ref.read(firestoreServiceProvider),
      ref.read(walletProvider.notifier),
      ref.read(databaseHelperProvider),
      ref.read(diceSessionServiceProvider),
      ref.read(diceTimerServiceProvider),
    );
    return notifier;
  },
);

// Convenience providers cho Dice
final diceCountdownProvider = Provider<int>(
  (ref) => ref.watch(diceProvider.select((s) => s.countdown)),
);

final diceSessionStatusProvider = Provider<SessionStatus>(
  (ref) => ref.watch(diceProvider.select((s) => s.sessionStatus)),
);

final diceActiveSessionProvider = Provider<BettingSessionModel?>(
  (ref) => ref.watch(diceProvider.select((s) => s.activeSession)),
);

final diceCurrentSessionBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(diceProvider.select((s) => s.currentSessionBets)),
);

final diceCurrentDraftProvider = Provider<BetDraftModel?>(
  (ref) => ref.watch(diceProvider.select((s) => s.currentDraft)),
);

final diceSettledBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(diceProvider.select((s) => s.settledBets)),
);

final diceRecentSessionsProvider = StreamProvider<List<BettingSessionModel>>((ref) {
  final service = ref.watch(diceSessionServiceProvider);
  return service.watchRecentSessions(limit: 10);
});
