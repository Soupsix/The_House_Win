import 'package:flutter/material.dart';
import 'calculator_screen.dart';
import 'monte_carlo_screen.dart';
import 'fallacy_screen.dart';
import 'strategy_compare_screen.dart';

class SimulationScreen extends StatelessWidget {
  const SimulationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16213E),
          title: const Text(
            'MÔ PHỎNG & PHÂN TÍCH',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFFF5F5F5),
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: Color(0xFFE94560),
            labelColor: Color(0xFFE94560),
            unselectedLabelColor: Color(0xFF9CA3AF),
            labelStyle: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            tabs: [
              Tab(text: 'CALCULATOR'),
              Tab(text: 'MONTE CARLO'),
              Tab(text: 'FALLACY'),
              Tab(text: 'STRATEGIES'),
            ],
          ),
        ),
        body: const TabBarView(
          physics: NeverScrollableScrollPhysics(), // Tắt swipe để tránh xung đột biểu đồ
          children: [
            CalculatorScreen(),
            MonteCarloScreen(),
            FallacyScreen(),
            StrategyCompareScreen(),
          ],
        ),
      ),
    );
  }
}
