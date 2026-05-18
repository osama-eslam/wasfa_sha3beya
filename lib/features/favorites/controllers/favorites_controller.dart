import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';
import 'package:wasfa_sha3beya/data/repositories/recipe_repository.dart';

class FavoritesController extends GetxController {
  final favoriteIds = <String>[].obs;
  final recipes = <Recipe>[].obs;
  final isLoading = true.obs;

  static const _storageKey = 'favorite_recipe_ids';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        favoriteIds.value = (jsonDecode(raw) as List).cast<String>();
      } catch (_) {
        // use empty
      }
    }
    await _resolveRecipes();
  }

  Future<void> _resolveRecipes() async {
    if (favoriteIds.isEmpty) {
      recipes.value = [];
      isLoading.value = false;
      return;
    }
    final all = await RecipeRepository().getAll();
    recipes.value =
        all.where((r) => favoriteIds.contains(r.id)).toList();
    isLoading.value = false;
  }

  bool isFavorite(String recipeId) => favoriteIds.contains(recipeId);

  Future<void> toggle(String recipeId) async {
    if (favoriteIds.contains(recipeId)) {
      favoriteIds.remove(recipeId);
    } else {
      favoriteIds.add(recipeId);
    }
    await _persist();
    await _resolveRecipes();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(favoriteIds.toList()));
  }
}
