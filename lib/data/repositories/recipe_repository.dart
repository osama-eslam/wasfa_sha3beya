import 'package:wasfa_sha3beya/core/services/recipe_service.dart';
import 'package:wasfa_sha3beya/data/models/recipe.dart';

class RecipeRepository {
  static final RecipeRepository _instance = RecipeRepository._();
  factory RecipeRepository() => _instance;
  RecipeRepository._();

  List<Recipe>? _cached;
  Future<void>? _loadingFuture;

  Future<void> _ensureLoaded() {
    if (_cached != null) return Future<void>.value();
    _loadingFuture ??= _loadInternal();
    return _loadingFuture!;
  }

  Future<void> _loadInternal() async {
    _cached = await RecipeService().getAllRecipes();
  }

  Future<List<Recipe>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cached!);
  }

  Future<Recipe?> findById(String id) async {
    await _ensureLoaded();
    try {
      return _cached!.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<int> get count async {
    await _ensureLoaded();
    return _cached!.length;
  }
}
