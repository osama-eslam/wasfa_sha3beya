import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class WheelPainter extends CustomPainter {
  final List<Recipe> recipes;
  final ColorScheme colorScheme;

  WheelPainter(this.recipes, this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segmentAngle = 2 * pi / recipes.length;

    for (int i = 0; i < recipes.length; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: i % 2 == 0
              ? [
                  colorScheme.primary.withValues(alpha: 0.9),
                  colorScheme.primary.withValues(alpha: 0.6),
                ]
              : [
                  colorScheme.tertiary.withValues(alpha: 0.9),
                  colorScheme.tertiary.withValues(alpha: 0.6),
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
        ..color = colorScheme.secondary.withValues(alpha: 0.35)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segmentAngle,
        segmentAngle,
        true,
        borderPaint,
      );

      final textColor = i % 2 == 0
          ? colorScheme.onPrimary
          : colorScheme.onTertiary;

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            fontSize: 16,
            color: textColor,
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

    final outerBorderPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, outerBorderPaint);

    final centerPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.08, centerPaint);

    final centerBorderPaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius * 0.08, centerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
