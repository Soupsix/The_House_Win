import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/match_model.dart';
import '../../domain/repositories/i_match_repository.dart';
import '../remote/football_api/football_api_client.dart';

class MatchRepositoryImpl implements IMatchRepository {
  final FirebaseFirestore _firestore;
  final FootballApiClient _apiClient;

  MatchRepositoryImpl({
    required FirebaseFirestore firestore,
    required FootballApiClient apiClient,
  })  : _firestore = firestore,
        _apiClient = apiClient;

  @override
  Future<void> syncMatches() async {
    final matches = await _apiClient.fetchMatches();
    
    final batch = _firestore.batch();
    for (var match in matches) {
      final docRef = _firestore.collection('matches').doc(match.id);
      batch.set(docRef, match.toFirestore(), SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  @override
  Stream<List<MatchModel>> getMatches() {
    return _firestore
        .collection('matches')
        .orderBy('utcDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => MatchModel.fromFirestore(doc)).toList();
    });
  }

  @override
  Future<MatchModel?> getMatchById(String id) async {
    final doc = await _firestore.collection('matches').doc(id).get();
    if (doc.exists) {
      return MatchModel.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> updateMatchScore(String id, int home, int away) async {
    await _firestore.collection('matches').doc(id).update({
      'scoreHome': home,
      'scoreAway': away,
    });
  }

  @override
  Future<void> createSimulatedMatch(MatchModel match) async {
    final docRef = _firestore.collection('matches').doc(match.id);
    await docRef.set(match.toFirestore());
  }
}