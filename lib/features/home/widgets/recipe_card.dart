import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/core/widgets/time_chip.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class RecipeCard extends StatefulWidget {
  final Recipe recipe;
  final int delay;
  final VoidCallback onTap;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.delay = 0,
    required this.onTap,
  });

  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _startTimer = Timer(
      Duration(milliseconds: widget.delay),
      () {
        if (mounted) _controller.forward();
      },
    );
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final theme = Theme.of(context);
    final firstStep = recipe.steps.isNotEmpty ? recipe.steps.first : '';

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            elevation: 6,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Hero(
                    tag: recipe.id,
                    child: ImageService.networkImage(
                      recipe.imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: ImageService.gridThumbnailWidth,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        firstStep,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Flexible(
                            child: TimeChip(
                              icon: Icons.schedule,
                              value: recipe.prepTime,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: widget.onTap,
                            style: TextButton.styleFrom(
                              minimumSize: Size.zero,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6,
                              ),
                              backgroundColor: Colors.teal.withValues(alpha: 0.15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              'شوف',
                              style: TextStyle(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
