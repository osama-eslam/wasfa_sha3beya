import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/core/widgets/fade_in_slide.dart';
import 'package:wasfa_sha3beya/core/widgets/info_box.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/features/favorites/controllers/favorites_controller.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favCtrl = Get.find<FavoritesController>();
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: ImageService.assetImage(
                AppConstants.backgroundImage, fit: BoxFit.cover,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, theme, favCtrl),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.cleaningMethod.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildCleaningMethodButton(context, theme),
                        ),
                      FadeInSlide(delay: 200, child: _buildInfoSection(theme)),
                      const SizedBox(height: 20),
                      FadeInSlide(
                        delay: 300,
                        child: _buildSectionTitle(context, theme, 'عن الطبق'),
                      ),
                      FadeInSlide(
                        delay: 400,
                        child: Card(
                          elevation: 4,
                          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              recipe.shortDescription,
                              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        delay: 500,
                        child: _buildSectionTitle(context, theme, 'المكونات'),
                      ),
                      FadeInSlide(
                        delay: 600,
                        child: _buildIngredients(theme, recipe.ingredients),
                      ),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        delay: 700,
                        child: _buildSectionTitle(context, theme, 'خطوات التحضير'),
                      ),
                      FadeInSlide(
                        delay: 800,
                        child: _buildSteps(theme, recipe.steps),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, ThemeData theme, FavoritesController favCtrl) {
    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      actions: [
        Obx(() {
          final fav = favCtrl.isFavorite(recipe.id);
          return Padding(
            padding: const EdgeInsets.all(8),
            child: CircleAvatar(
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
              child: IconButton(
                icon: Icon(
                  fav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: fav ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  size: 22,
                ),
                onPressed: () => favCtrl.toggle(recipe.id),
              ),
            ),
          );
        }),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recipe.title,
            style: TextStyle(
              fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: recipe.id,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                child: ImageService.networkImage(
                  recipe.imageUrl,
                  fit: BoxFit.cover,
                  memCacheWidth: ImageService.detailImageWidth,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
          child: IconButton(
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_ios
                  : Icons.arrow_back_ios,
              color: theme.colorScheme.onSurface,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildCleaningMethodButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => _showCleaningSheet(context, theme),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primary.withValues(alpha: 0.7),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cleaning_services_rounded,
              color: theme.colorScheme.onPrimary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              'اعرض طريقة التنظيف',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCleaningSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cleaning_services_rounded,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'طريقة التنظيف',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: theme.colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      recipe.cleaningMethod,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('تم'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    return Card(
      elevation: 6,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InfoBox(icon: Icons.schedule, title: 'وقت التحضير', value: recipe.prepTime),
              InfoBox(icon: Icons.local_fire_department, title: 'وقت الطبخ', value: recipe.cookTime),
              InfoBox(icon: Icons.category, title: 'النوع', value: recipe.category),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 5, height: 22,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(ThemeData theme, List<String> ingredients) {
    return Card(
      elevation: 4,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: ingredients.map((i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(i, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
                ),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildSteps(ThemeData theme, List<String> steps) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key + 1;
        return Card(
          elevation: 3,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsetsDirectional.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  radius: 14,
                  child: Text(
                    "$i",
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.value,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
