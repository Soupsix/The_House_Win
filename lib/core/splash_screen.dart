import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 100,
              color: Color(0xFFE94560),
            ),
            SizedBox(height: 24),
            Text(
              'The House Wins',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFFF5F5F5),
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(
              color: Color(0xFFE94560),
            ),
          ],
        ),
      ),
    );
  }
}
