import 'dart:math';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/data/repositories/recipe_repository.dart';

class HomeController extends GetxController {
  final RecipeRepository _repo = RecipeRepository();

  final recipes = <Recipe>[].obs;
  final filteredRecipes = <Recipe>[].obs;
  final selectedCategory = AppConstants.categories.first.name.obs;
  final searchQuery = ''.obs;
  final isLoading = true.obs;

  Map<String, List<Recipe>> _categoryMap = {};

  @override
  void onInit() {
    super.onInit();
    _loadRecipes();
    debounce(searchQuery, (_) => _applyFilters(), time: const Duration(milliseconds: 300));
  }

  Future<void> _loadRecipes() async {
    final all = await _repo.getAll();
    final shuffled = List<Recipe>.from(all)..shuffle(Random());

    _categoryMap = {};
    for (final cat in AppConstants.categories) {
      if (cat.name == AppConstants.categories.first.name) {
        _categoryMap[cat.name] = List.from(shuffled);
      } else {
        _categoryMap[cat.name] = shuffled
            .where((r) => r.category.toLowerCase().contains(cat.name.toLowerCase()))
            .toList();
      }
    }

    recipes.value = shuffled;
    filteredRecipes.value = List.from(_categoryMap[selectedCategory.value]!);
    isLoading.value = false;
  }

  void selectCategory(String name) {
    if (selectedCategory.value == name) return;
    selectedCategory.value = name;
    _applyFilters();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();
    var base = List<Recipe>.from(_categoryMap[selectedCategory.value] ?? []);

    if (query.isNotEmpty) {
      base = base.where((r) =>
        r.title.toLowerCase().contains(query) ||
        r.shortDescription.toLowerCase().contains(query)
      ).toList();
    }

    filteredRecipes.value = base;
  }
}
