import 'dart:math' as math;

import 'package:flutter/material.dart';

class EidCategoryCard extends StatefulWidget {
  final VoidCallback onTap;

  const EidCategoryCard({super.key, required this.onTap});

  @override
  State<EidCategoryCard> createState() => _EidCategoryCardState();
}

class _EidCategoryCardState extends State<EidCategoryCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final pulse = (math.sin(t * math.pi * 2) + 1) / 2;
          final sparkle = (math.sin(t * math.pi * 4 + 1) + 1) / 2;
          return Container(
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFFFD700).withValues(alpha: 0.25 + pulse * 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.1 + pulse * 0.2),
                  blurRadius: 6 + pulse * 10,
                  spreadRadius: pulse,
                ),
              ],
              gradient: LinearGradient(
                colors: [
                  Color.lerp(const Color(0xFF1A3A2A), const Color(0xFF0D5C3A), t)!,
                  Color.lerp(const Color(0xFF0D5C3A), const Color(0xFF1A3A2A), t)!,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: -6,
                  left: 20,
                  child: Icon(Icons.star_rounded, size: 10,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3 + pulse * 0.4),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 40,
                  child: Icon(Icons.star_rounded, size: 7,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1 + sparkle * 0.5),
                  ),
                ),
                Positioned(
                  bottom: -4,
                  left: 50,
                  child: Icon(Icons.star_rounded, size: 8,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1 + sparkle * 0.4),
                  ),
                ),
                Positioned(
                  top: -3,
                  right: 80,
                  child: Icon(Icons.auto_awesome, size: 8,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.1 + pulse * 0.35),
                  ),
                ),
                Positioned(
                  bottom: 2,
                  left: 90,
                  child: Icon(Icons.auto_awesome, size: 6,
                    color: const Color(0xFFFFD700).withValues(alpha: 0.05 + sparkle * 0.3),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: 6),
                    Container(
                      width: 4,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.7 + pulse * 0.3),
                            const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFD700).withValues(alpha: 0.15 + pulse * 0.15),
                            const Color(0xFFD4AF37).withValues(alpha: 0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.2 + pulse * 0.35),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.celebration_rounded,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.65 + pulse * 0.3),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'أكلات عيد الأضحى',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.lerp(
                                const Color(0xFFFFF8E7),
                                const Color(0xFFFFD700),
                                pulse,
                              )!,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'وصفات العيد المبارك',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10,
                              color: const Color(0xFFFFD700).withValues(alpha: 0.5 + pulse * 0.3),
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.12 + pulse * 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: const Color(0xFFFFD700).withValues(alpha: 0.5 + pulse * 0.35),
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
