import '../../domain/models/match_model.dart';
import '../../domain/enums/match_status.dart';
import '../../domain/repositories/i_match_repository.dart';

import '../firebase/firestore_service.dart';
import '../local/matches_local_dao.dart';
import '../remote/football_api/football_api_client.dart';

class MatchRepositoryImpl implements IMatchRepository {
  final FootballApiClient apiClient;
  final FirestoreService firestoreService;
  final MatchesLocalDao localDao;

  MatchRepositoryImpl({
    required this.apiClient,
    required this.firestoreService,
    required this.localDao,
  });

  @override
  Future<List<MatchModel>> syncTodayMatches() async {
    final matches = await apiClient.fetchMatches();

    for (final match in matches) {
      await firestoreService.saveMatchInFirestore(
        match.id,
        match.toFirestore(),
      );

      await localDao.insertMatch(match);
    }

    return matches;
  }

  @override
  Future<List<MatchModel>> getCachedMatches() async {
    return await localDao.getAllMatches();
  }

  @override
  Future<void> saveMatch(MatchModel match) async {
    await firestoreService.saveMatchInFirestore(
      match.id,
      match.toFirestore(),
    );

    await localDao.insertMatch(match);
  }

  @override
  Future<void> updateMatch(MatchModel match) async {
    await firestoreService.saveMatchInFirestore(
      match.id,
      match.toFirestore(),
    );

    await localDao.updateMatch(match);
  }

  @override
  Future<MatchModel?> getMatchById(String id) async {
    return await localDao.getMatch(id);
  }

  @override
  Future<void> createSimulatedMatch(MatchModel match) async {
    final simulated = match.copyWith(
      isSimulated: true,
    );

    await firestoreService.saveMatchInFirestore(
      simulated.id,
      simulated.toFirestore(),
    );

    await localDao.insertMatch(simulated);
  }

  @override
  Future<void> overrideResult(
      String matchId,
      MatchResult result,
      ) async {
    await firestoreService.settleMatchInFirestore(
      matchId,
      result.name,
    );

    final match = await localDao.getMatch(matchId);

    if (match == null) return;

    final updated = match.copyWith(
      result: result,
    );

    await localDao.updateMatch(updated);
  }
}