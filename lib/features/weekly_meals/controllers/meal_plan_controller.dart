import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanController extends GetxController {
  final title = 'أكل الأسبوع ده'.obs;
  final meals = List.generate(7, (_) => '').obs;

  static const _storageKey = 'meal_plan_v1';

  static const dayNames = [
    'السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة',
  ];

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
        final data = jsonDecode(raw) as Map;
        title.value = data['title'] as String? ?? 'أكل الأسبوع ده';
        final list = data['meals'] as List?;
        if (list != null) {
          for (var i = 0; i < 7 && i < list.length; i++) {
            meals[i] = list[i] as String? ?? '';
          }
        }
      } catch (_) {
        // use defaults
      }
    }
  }

  Future<void> updateTitle(String newTitle) async {
    title.value = newTitle;
    await _persist();
  }

  Future<void> updateMeal(int dayIndex, String meal) async {
    meals[dayIndex] = meal;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'title': title.value,
      'meals': meals.toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
