class Recipe {
  final String id;
  final String title;
  final String image;
  final String shortDescription;
  final List<String> ingredients;
  final List<String> steps;
  final String prepTime;
  final String cookTime;
  final String category;
  final String extra;

  Recipe({
    required this.id,
    required this.title,
    required this.image,
    required this.shortDescription,
    required this.ingredients,
    required this.steps,
    required this.prepTime,
    required this.cookTime,
    required this.category,
    required this.extra,
  });

  factory Recipe.fromMap(Map<String, dynamic> m, int index) {
    return Recipe(
      id: index.toString(),
      title: m['name'] ?? '',
      image: m['image'] ?? '',
      shortDescription: m['funTipOnOpen'] ?? '',
      ingredients: List<String>.from(m['ingredients'] ?? []),
      steps: List<String>.from(m['steps'] ?? []),
      prepTime: m['time'] ?? '',
      cookTime: '',
      category: m['type'] ?? '',
      extra: m['extra'] ?? '',
    );
  }

  String get imageUrl =>
      'https://wvgqvkhkbsjmtumpmhsh.supabase.co/storage/v1/object/public/recipes/$image';
}
