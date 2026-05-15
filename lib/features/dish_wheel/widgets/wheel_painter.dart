import 'dart:ui' as ui;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/data/models/dish_person.dart';

class DishWheelPainter extends CustomPainter {
  final List<DishPerson> people;
  final List<ui.Image> images;
  final DishPerson? selected;

  DishWheelPainter(this.people, this.images, this.selected);

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
                  Colors.teal.shade300.withValues(alpha: 0.8),
                  Colors.teal.shade600.withValues(alpha: 0.9),
                ]
              : [
                  Colors.cyan.shade300.withValues(alpha: 0.8),
                  Colors.cyan.shade600.withValues(alpha: 0.9),
                ],
        )
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        i * segment, segment, true, paint,
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
