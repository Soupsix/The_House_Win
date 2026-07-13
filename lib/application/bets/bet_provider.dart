import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'bet_state.dart';
import 'bet_notifier.dart';
import '../../domain/models/bet_model.dart';
import '../../data/firebase/firestore_service.dart';
import '../../data/local/database_helper.dart';
import '../wallet/wallet_provider.dart';
import '../matches/match_provider.dart';
// Đã chuyển các config của Tài/Xỉu sang dice_provider.dart

// Provider cho BetNotifier
final betProvider = StateNotifierProvider<BetNotifier, BetState>(
  (ref) {
    final notifier = BetNotifier(
      ref,
      ref.read(firestoreServiceProvider),
      ref.read(walletProvider.notifier),
      ref.read(databaseHelperProvider),
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

// Provider lấy danh sách cược đã giải quyết (chỉ của bóng đá vì Dice đã tách)
final settledBetsProvider = Provider<List<BetModel>>(
  (ref) => ref.watch(betProvider.select((s) => s.settledBets)),
);
