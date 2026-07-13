import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/match_model.dart';
import '../../data/repositories/match_analysis_repository.dart';

final matchAnalysisProvider = FutureProvider.family<String, MatchModel>((ref, match) async {
  final repository = ref.watch(matchAnalysisRepositoryProvider);
  return await repository.analyzeMatch(match);
});
