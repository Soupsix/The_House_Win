import '../models/match_model.dart';

abstract class IMatchRepository {
  Future<void> syncMatches();
  Stream<List<MatchModel>> getMatches();
  Future<MatchModel?> getMatchById(String id);
  Future<void> updateMatchScore(String id, int home, int away);
  Future<void> createSimulatedMatch(MatchModel match);
}