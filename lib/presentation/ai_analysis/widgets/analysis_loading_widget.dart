import 'package:flutter/material.dart';

class AnalysisLoadingWidget extends StatelessWidget {
  const AnalysisLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
