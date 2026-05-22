import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/features/detail/recipe_detail_page.dart';
import 'package:wasfa_sha3beya/features/home/widgets/recipe_card.dart';

class EidRecipesPage extends StatefulWidget {
  const EidRecipesPage({super.key});

  @override
  State<EidRecipesPage> createState() => _EidRecipesPageState();
}

class _EidRecipesPageState extends State<EidRecipesPage>
    with SingleTickerProviderStateMixin {
  List<Recipe>? _recipes;
  bool _loading = true;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _load();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await rootBundle.load('assets/data/Eid_food.json');
      final jsonString = utf8.decode(data.buffer.asUint8List());
      final List parsed = jsonDecode(jsonString);
      final list = parsed
          .asMap()
          .entries
          .map((e) => Recipe.fromMap(e.value, e.key))
          .toList();
      setState(() {
        _recipes = list;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: _bgController,
      builder: (context, _) {
        final shimmer = _bgController.value;
        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(
                          const Color(0xFF0D5C3A),
                          const Color(0xFF1A4A2E),
                          shimmer,
                        )!,
                        Color.lerp(
                          const Color(0xFF1A3A2A),
                          const Color(0xFF0D3A28),
                          shimmer,
                        )!,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -40,
                right: -40,
                child: Icon(
                  Icons.nights_stay_rounded,
                  size: 160,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.04),
                ),
              ),
              Positioned(
                bottom: -30,
                left: -30,
                child: Transform.rotate(
                  angle: math.pi / 4,
                  child: Icon(
                    Icons.star_rounded,
                    size: 120,
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.03),
                  ),
                ),
              ),
              CustomScrollView(
                slivers: [
                  _buildHeader(theme, shimmer),
                  if (_loading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_recipes == null || _recipes!.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('لا توجد وصفات')),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final r = _recipes![index];
                            return RecipeCard(
                              key: ValueKey('eid_${r.id}'),
                              recipe: r,
                              delay: index * 40,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RecipeDetailPage(recipe: r),
                                ),
                              ),
                            );
                          },
                          childCount: _recipes!.length,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, double shimmer) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      backgroundColor: const Color(0xFF0D5C3A),
      surfaceTintColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.celebration_rounded,
                color: Color.lerp(
                  const Color(0xFFD4AF37),
                  const Color(0xFFFFF8E7),
                  shimmer,
                )!,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'أكلات عيد الأضحى',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  color: Color.lerp(
                    const Color(0xFFFFF8E7),
                    const Color(0xFFD4AF37),
                    shimmer,
                  )!,
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFB8860B),
                  const Color(0xFFD4AF37),
                  shimmer,
                )!,
                Color.lerp(
                  const Color(0xFF0D5C3A),
                  const Color(0xFF1A4A2E),
                  shimmer,
                )!,
              ],
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: 20,
                top: 20,
                child: Icon(
                  Icons.star_rounded,
                  size: 28,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15 + shimmer * 0.1),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 20,
                child: Icon(
                  Icons.star_rounded,
                  size: 22,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.1 + shimmer * 0.08),
                ),
              ),
              Positioned(
                left: 60,
                bottom: 10,
                child: Icon(
                  Icons.nights_stay_rounded,
                  size: 18,
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.06 + shimmer * 0.04),
                ),
              ),
            ],
          ),
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.black.withValues(alpha: 0.3),
          child: IconButton(
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_ios
                  : Icons.arrow_back_ios,
              color: const Color(0xFFFFF8E7),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }
}
