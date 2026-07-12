import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bet_state.dart';
import 'bet_notifier.dart';
import '../../domain/models/bet_model.dart';
import '../../domain/models/betting_session_model.dart';
import '../../domain/enums/session_status.dart';
import '../../data/firebase/betting_session_service.dart';
import '../../core/services/session_timer_service.dart';
import '../wallet/wallet_provider.dart';
import '../matches/match_provider.dart';

// Provider cho BettingSessionService
final bettingSessionServiceProvider = Provider<BettingSessionService>(
  (ref) => BettingSessionService(),
);

// Provider cho SessionTimerService
final sessionTimerServiceProvider = Provider<SessionTimerService>(
  (ref) => SessionTimerService(ref.read(bettingSessionServiceProvider)),
);

// Provider cho BetNotifier
final betProvider = StateNotifierProvider<BetNotifier, BetState>(
  (ref) {
    final notifier = BetNotifier(
      ref.read(firestoreServiceProvider),
      ref.read(walletProvider.notifier),
      ref.read(databaseHelperProvider),
      ref.read(bettingSessionServiceProvider),
      ref.read(sessionTimerServiceProvider),
    );
    
    // Đăng ký BetNotifier làm BetsSettler cho MatchNotifier để tự động thanh toán cược bóng đá khi trận kết thúc
    ref.read(matchProvider.notifier).setBetsSettler(notifier);
    
    return notifier;
  },
);

// Convenience providers cho các module khác dùng
// Chỉ rebuild khi đúng field đó thay đổi — không watch toàn bộ betProvider

// Provider lấy danh sách các cược bóng đá đang chờ kết quả
final pendingBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(betProvider.select((s) => s.pendingBets)),
);

// Provider lấy số lượng cược bóng đá đang chờ kết quả
final pendingBetsCountProvider = Provider<int>(
  (ref) => ref.watch(betProvider.select((s) => s.pendingBets.length)),
);

// Provider lấy đơn cược nháp hiện tại
final currentDraftProvider = Provider<BetDraftModel?>(
  (ref) => ref.watch(betProvider.select((s) => s.currentDraft)),
);

// Provider đếm ngược giây còn lại trong phiên Tài Xỉu
final countdownProvider = Provider<int>(
  (ref) => ref.watch(betProvider.select((s) => s.countdown)),
);

// Provider lấy trạng thái phiên cược hiện tại
final sessionStatusProvider = Provider<SessionStatus>(
  (ref) => ref.watch(betProvider.select((s) => s.sessionStatus)),
);

// Provider lấy phiên cược đang hoạt động
final activeSessionProvider = Provider<BettingSessionModel?>(
  (ref) => ref.watch(betProvider.select((s) => s.activeSession)),
);

// Provider lấy các cược của user trong phiên hiện tại
final currentSessionBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(betProvider.select((s) => s.currentSessionBets)),
);

// Provider lấy danh sách cược đã giải quyết (cả bóng đá và Tài Xỉu)
final settledBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(betProvider.select((s) => s.settledBets)),
);

// Provider stream 10 phiên gần nhất đã kết toán (để hiển thị lịch sử)
final recentSessionsProvider = StreamProvider<List<BettingSessionModel>>((ref) {
  final service = ref.watch(bettingSessionServiceProvider);
  return service.watchRecentSessions(limit: 10);
});
