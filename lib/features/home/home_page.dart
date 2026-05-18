import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/services/image_service.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/features/detail/recipe_detail_page.dart';
import 'package:wasfa_sha3beya/features/home/controllers/home_controller.dart';
import 'package:wasfa_sha3beya/features/home/widgets/category_row.dart';
import 'package:wasfa_sha3beya/features/home/widgets/recipe_card.dart';
import 'package:wasfa_sha3beya/features/home/widgets/search_card.dart';
import 'package:wasfa_sha3beya/features/main_layout/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _ctrl = Get.put(HomeController());
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('يا ترى هتاكل إيه؟'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchCard(
              controller: _searchCtrl,
              onChanged: (v) => _ctrl.onSearchChanged(v),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ImageService.assetImage(
                AppConstants.backgroundImage,
                fit: BoxFit.cover,
                color: theme.brightness == Brightness.dark
                    ? Colors.black.withValues(alpha: 0.4)
                    : Colors.black.withValues(alpha: 0.1),
                colorBlendMode: BlendMode.darken,
              ),
            ),
            Obx(() {
              if (_ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Obx(() => CategoryRow(
                      selectedCategory: _ctrl.selectedCategory.value,
                      onCategorySelected: (name) => _ctrl.selectCategory(name),
                    )),
                    const SizedBox(height: 12),
                    Expanded(child: _buildGrid()),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return Obx(() {
      final list = _ctrl.filteredRecipes;
      if (list.isEmpty) return const Center(child: Text('لا توجد وصفات'));

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
          return GridView.builder(
            cacheExtent: 1000,
            addAutomaticKeepAlives: true,
            itemCount: list.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final r = list[index];
              return RecipeCard(
                key: ValueKey(r.id),
                recipe: r,
                delay: index * 40,
                onTap: () => _openDetail(r),
              );
            },
          );
        },
      );
    });
  }

  void _openDetail(Recipe r) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => RecipeDetailPage(recipe: r)));
  }
}
