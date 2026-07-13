import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../domain/models/match_model.dart';
import '../../../application/matches/match_analysis_provider.dart';

class AiAnalysisBottomSheet extends ConsumerWidget {
  final MatchModel match;

  const AiAnalysisBottomSheet({super.key, required this.match});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysisAsyncValue = ref.watch(matchAnalysisProvider(match));

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
                  SizedBox(width: 8),
                  Text(
                    'Phân tích AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 24),
          
          // Content
          Expanded(
            child: analysisAsyncValue.when(
              data: (markdownData) => Markdown(
                data: markdownData,
                padding: const EdgeInsets.only(bottom: 24),
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                  h1: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  h2: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  h3: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(color: Colors.amber),
                  strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    SizedBox(height: 16),
                    Text(
                      'AI đang phân tích dữ liệu trận đấu...\nVui lòng đợi giây lát.',
                      style: TextStyle(color: Colors.white54, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Text(
                  'Lỗi: $error',
                  style: const TextStyle(color: Colors.redAccent),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showAiAnalysisBottomSheet(BuildContext context, MatchModel match) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: AiAnalysisBottomSheet(match: match),
    ),
  );
}
