import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/data/models/dish_person.dart';

class DishWheelPainter extends CustomPainter {
  final List<DishPerson> people;
  final List<ui.Image> images;
  final DishPerson? selected;
  final ColorScheme colorScheme;

  DishWheelPainter(
    this.people,
    this.images,
    this.selected,
    this.colorScheme,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (people.isEmpty || images.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final segment = 2 * pi / people.length;

    for (int i = 0; i < people.length; i++) {
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          radius,
          i % 2 == 0
              ? [
                  colorScheme.primary.withValues(alpha: 0.85),
                  colorScheme.primary.withValues(alpha: 0.95),
                ]
              : [
                  colorScheme.tertiary.withValues(alpha: 0.85),
                  colorScheme.tertiary.withValues(alpha: 0.95),
                ],
        )
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segment, segment, true, paint,
      );

      final strokePaint = Paint()
        ..color = colorScheme.secondary.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segment, segment, true, strokePaint,
      );

      final angle = i * segment + segment / 2;
      final iconSize = radius * 0.25;
      final dx = center.dx + cos(angle) * radius * 0.55 - iconSize / 2;
      final dy = center.dy + sin(angle) * radius * 0.55 - iconSize / 2;
      if (i < images.length) {
        canvas.drawImageRect(
          images[i],
          Rect.fromLTWH(0, 0, images[i].width.toDouble(), images[i].height.toDouble()),
          Rect.fromLTWH(dx, dy, iconSize, iconSize),
          Paint(),
        );
      }
    }

    final centerPaint = Paint()
      ..color = colorScheme.surface
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.12, centerPaint);

    final centerBorderPaint = Paint()
      ..color = colorScheme.secondary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(center, radius * 0.12, centerBorderPaint);

    final outerBorderPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, outerBorderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
