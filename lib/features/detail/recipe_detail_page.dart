import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/core/widgets/fade_in_slide.dart';
import 'package:wasfa_sha3beya/core/widgets/info_box.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailPage({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: ImageService.assetImage(
                AppConstants.backgroundImage, fit: BoxFit.cover,
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeInSlide(delay: 200, child: _buildInfoSection()),
                      const SizedBox(height: 20),
                      FadeInSlide(
                        delay: 300,
                        child: _buildSectionTitle(context, 'عن الطبق'),
                      ),
                      FadeInSlide(
                        delay: 400,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              recipe.shortDescription,
                              style: const TextStyle(fontSize: 15, height: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        delay: 500,
                        child: _buildSectionTitle(context, 'المكونات'),
                      ),
                      FadeInSlide(
                        delay: 600,
                        child: _buildIngredients(recipe.ingredients),
                      ),
                      const SizedBox(height: 24),
                      FadeInSlide(
                        delay: 700,
                        child: _buildSectionTitle(context, 'خطوات التحضير'),
                      ),
                      FadeInSlide(
                        delay: 800,
                        child: _buildSteps(recipe.steps),
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

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 330,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            recipe.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white,
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black45, Colors.transparent],
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
          backgroundColor: Colors.black45,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InfoBox(icon: Icons.schedule, title: 'وقت التحضير', value: recipe.prepTime),
            InfoBox(icon: Icons.local_fire_department, title: 'وقت الطبخ', value: recipe.cookTime),
            InfoBox(icon: Icons.category, title: 'النوع', value: recipe.category),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 5, height: 22,
            decoration: BoxDecoration(
              color: Colors.teal,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients(List<String> ingredients) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: ingredients.map((i) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.teal.shade600, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(i, style: const TextStyle(fontSize: 15))),
              ],
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildSteps(List<String> steps) {
    return Column(
      children: steps.asMap().entries.map((e) {
        final i = e.key + 1;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 14,
                  child: Text(
                    "$i",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 15, height: 1.5),
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
