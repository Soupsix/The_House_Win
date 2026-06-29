import 'package:flutter/material.dart';

class RedWarningOverlay extends StatelessWidget {
  const RedWarningOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.red.withOpacity(0.3),
    );
  }
}
