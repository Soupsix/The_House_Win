import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'match_state.dart';
import 'match_notifier.dart';
import '../../data/remote/football_api/football_api_client.dart';
import '../../data/local/database_helper.dart';
import '../../domain/models/match_model.dart';
import '../wallet/wallet_provider.dart'; // import để có firestoreServiceProvider

// Provider cho FootballApiClient
final footballApiClientProvider = Provider<FootballApiClient>(
  (ref) => FootballApiClient(),
);

// Provider cho DatabaseHelper
final databaseHelperProvider = Provider<DatabaseHelper>(
  (ref) => DatabaseHelper(),
);

// Provider cho MatchNotifier
final matchProvider = StateNotifierProvider<MatchNotifier, MatchState>(
  (ref) => MatchNotifier(
    ref.read(footballApiClientProvider),
    ref.read(firestoreServiceProvider),
    ref.read(databaseHelperProvider),
  ),
);

// Convenience providers cho các module khác dùng
// Chỉ rebuild khi đúng field đó thay đổi — không watch toàn bộ matchProvider

// Provider lấy danh sách các trận đấu sắp diễn ra
final scheduledMatchesProvider = Provider<List<MatchModel>>(
  (ref) => ref.watch(matchProvider.select((s) => s.scheduledMatches)),
);

// Provider lấy danh sách các trận đấu đang diễn ra trực tiếp
final liveMatchesProvider = Provider<List<MatchModel>>(
  (ref) => ref.watch(matchProvider.select((s) => s.liveMatches)),
);

// Provider lấy danh sách các trận đấu đã kết thúc
final finishedMatchesProvider = Provider<List<MatchModel>>(
  (ref) => ref.watch(matchProvider.select((s) => s.finishedMatches)),
);

// Provider lấy trận đấu đang được chọn để xem chi tiết
final selectedMatchProvider = Provider<MatchModel?>(
  (ref) => ref.watch(matchProvider.select((s) => s.selectedMatch)),
);
