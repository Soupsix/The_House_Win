import 'dart:math';
import 'package:flutter/material.dart';
import '../../../domain/models/spin_segment_model.dart';

class SpinWheelPainter extends CustomPainter {
  final List<SpinSegmentModel> segments;
  final double rotationAngle;

  SpinWheelPainter({
    required this.segments,
    required this.rotationAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Use total probability as 360 degrees (1.0 = 2 * pi)
    // Wait, the wheel UI is usually evenly distributed even if probabilities differ!
    // If we draw segments based on probability, x10 (1.1%) will be a tiny sliver!
    // For a spin wheel, to make it visually pleasing and hide the exact physics (which is allowed as long as we show the probability table clearly),
    // we should draw EVEN segments, but the SERVER uses the probability to pick the segment.
    // The prompt says: "Hiển thị vòng quay (CustomPainter hoặc animation package)".
    // Let's draw them evenly.
    final sweepAngle = 2 * pi / segments.length;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    canvas.translate(-center.dx, -center.dy);

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final startAngle = i * sweepAngle;

      paint.color = _parseColor(segment.colorHex);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      // Draw border
      paint.color = Colors.white;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      paint.style = PaintingStyle.fill;

      // Draw Text
      _drawText(
        canvas: canvas,
        center: center,
        radius: radius,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
        text: segment.label,
      );
    }

    canvas.restore();
  }

  void _drawText({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double startAngle,
    required double sweepAngle,
    required String text,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black54, blurRadius: 2)],
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final textAngle = startAngle + sweepAngle / 2;
    final r = radius * 0.65; // Position text at 65% of radius

    canvas.save();
    canvas.translate(
      center.dx + r * cos(textAngle),
      center.dy + r * sin(textAngle),
    );
    // Rotate text to face outward
    canvas.rotate(textAngle + pi / 2);
    
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
    canvas.restore();
  }

  Color _parseColor(String hexCode) {
    hexCode = hexCode.replaceAll('#', '');
    if (hexCode.length == 6) {
      hexCode = 'FF$hexCode';
    }
    return Color(int.parse(hexCode, radix: 16));
  }

  @override
  bool shouldRepaint(covariant SpinWheelPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle ||
        oldDelegate.segments != segments;
  }
}
