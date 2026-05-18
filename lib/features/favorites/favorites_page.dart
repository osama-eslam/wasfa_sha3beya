import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/features/detail/recipe_detail_page.dart';
import 'package:wasfa_sha3beya/features/favorites/controllers/favorites_controller.dart';
import 'package:wasfa_sha3beya/features/home/widgets/recipe_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.find<FavoritesController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأكلات المفضلة'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.recipes.isEmpty) {
                return _EmptyFavorites(theme: theme);
              }
              final list = controller.recipes;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount =
                      constraints.maxWidth > 600 ? 3 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                    cacheExtent: 500,
                    itemCount: list.length,
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final r = list[index];
                      return RecipeCard(
                        key: ValueKey(r.id),
                        recipe: r,
                        delay: index * 40,
                        onTap: () => _openDetail(context, r),
                      );
                    },
                  );
                },
              );
            }),
          ),
          const BannerAdWidget(),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Recipe r) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: r)),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final ThemeData theme;
  const _EmptyFavorites({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_outline_rounded,
                size: 72, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)),
            const SizedBox(height: 16),
            Text(
              'لا توجد وصفات مفضلة بعد',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'اضغط على القلب ♡ لإضافة وصفاتك المفضلة',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
