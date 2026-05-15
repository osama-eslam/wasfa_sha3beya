import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class WheelPainter extends CustomPainter {
  final List<Recipe> recipes;

  WheelPainter(this.recipes);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / recipes.length;

    for (int i = 0; i < recipes.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            i % 2 == 0 ? Colors.teal.shade400 : Colors.teal.shade300,
            Colors.teal.shade50,
          ],
          center: Alignment.center,
          radius: 1.0,
        ).createShader(Rect.fromCircle(center: center, radius: radius));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        paint,
      );

      final borderPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angle = i * segmentAngle + segmentAngle / 2;
      final numberRadius = radius * 0.85;
      final offset = Offset(
        center.dx + numberRadius * cos(angle) - textPainter.width / 2,
        center.dy + numberRadius * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
