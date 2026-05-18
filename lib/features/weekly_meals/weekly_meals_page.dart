import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/features/weekly_meals/controllers/meal_plan_controller.dart';

class WeeklyMealsPage extends StatelessWidget {
  const WeeklyMealsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MealPlanController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('جدول أكل الأسبوع'),
      ),
      body: Obx(() {
            controller.meals.length;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _WeekTitleCard(controller: controller, theme: theme),
                const SizedBox(height: 20),
                ...List.generate(7, (i) => _DayMealCard(
                      index: i,
                      controller: controller,
                      theme: theme,
                    )),
                const SizedBox(height: 12),
                const BannerAdWidget(),
                const SizedBox(height: 12),
              ],
            );
          }),
    );
  }
}

class _WeekTitleCard extends StatelessWidget {
  final MealPlanController controller;
  final ThemeData theme;

  const _WeekTitleCard({
    required this.controller,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _editTitle(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.edit_outlined,
                      size: 18, color: theme.colorScheme.onPrimary.withValues(alpha: 0.9)),
                ),
              ),
              const Spacer(),
              Icon(Icons.restaurant_menu_rounded,
                  size: 28, color: theme.colorScheme.onPrimary.withValues(alpha: 0.4)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.title.value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'خطة الأكل لهذا الأسبوع',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onPrimary.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  void _editTitle(BuildContext context) {
    final ctrl = TextEditingController(text: controller.title.value);
    Get.dialog(
      AlertDialog(
        title: const Text('تعديل عنوان الأسبوع'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'مثال: أكل الأسبوع ده',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final t = ctrl.text.trim();
              if (t.isNotEmpty) {
                controller.updateTitle(t);
                Get.back();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}

class _DayMealCard extends StatelessWidget {
  final int index;
  final MealPlanController controller;
  final ThemeData theme;

  const _DayMealCard({
    required this.index,
    required this.controller,
    required this.theme,
  });

  static const dayColors = [
    0xFFE53935, 0xFFFB8C00, 0xFFFDD835, 0xFF43A047,
    0xFF1E88E5, 0xFF8E24AA, 0xFF00ACC1,
  ];

  Color get _accent => Color(dayColors[index % dayColors.length]);

  @override
  Widget build(BuildContext context) {
    final meal = controller.meals[index];
    final hasMeal = meal.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _editMeal(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(Icons.restaurant_outlined,
                        color: _accent, size: 20),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        MealPlanController.dayNames[index],
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        hasMeal ? meal : 'ماذا سنطبخ اليوم؟',
                        style: TextStyle(
                          fontSize: 13,
                          color: hasMeal
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              hasMeal ? FontWeight.w500 : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _editMeal(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.edit_outlined,
                        color: _accent, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editMeal(BuildContext context) {
    final ctrl = TextEditingController(text: controller.meals[index]);
    Get.dialog(
      AlertDialog(
        title: Text('طبخة ${MealPlanController.dayNames[index]}'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textDirection: TextDirection.rtl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'ماذا سنطبخ اليوم؟',
            prefixIcon: Icon(Icons.restaurant_outlined),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              controller.updateMeal(index, ctrl.text.trim());
              Get.back();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }
}
