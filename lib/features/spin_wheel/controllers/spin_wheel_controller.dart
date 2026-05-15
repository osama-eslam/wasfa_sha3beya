import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class SpinWheelController {
  double angle = 0.0;
  bool isSpinning = false;
  bool isCardShown = false;
  Recipe? selectedRecipe;
  final Random random = Random();
  AnimationController? _controller;

  void attach(AnimationController controller) {
    _controller = controller;
  }

  void detach() {
    _controller?.removeStatusListener(_onSpinComplete);
    _controller = null;
  }

  void spinWithAngle(double spinAngle, VoidCallback onUpdate, VoidCallback onComplete) {
    if (isSpinning) return;

    isSpinning = true;
    selectedRecipe = null;

    final tween = Tween<double>(begin: angle, end: angle + spinAngle);
    final animation = tween.animate(
      CurvedAnimation(parent: _controller!, curve: Curves.decelerate),
    );

    animation.addListener(() {
      angle = animation.value;
      onUpdate();
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        onComplete();
      }
    });

    _controller!.reset();
    _controller!.forward();
  }

  void _onSpinComplete(AnimationStatus status) {}

  void startSpin(VoidCallback onUpdate, VoidCallback onComplete) {
    final randomEnd = random.nextDouble() * 2 * pi + 6 * 2 * pi;
    spinWithAngle(randomEnd, onUpdate, onComplete);
  }

  int calculateWinnerIndex(int totalSegments) {
    final segmentAngle = 2 * pi / totalSegments;
    final adjustedAngle = angle % (2 * pi);
    int index = totalSegments - (adjustedAngle ~/ segmentAngle) - 1;
    if (index < 0) index += totalSegments;
    return index;
  }
}
