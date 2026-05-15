import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:wasfa_sha3beya/core/app_constants.dart';
import 'package:wasfa_sha3beya/core/widgets/banner_ad_widget.dart';
import 'package:wasfa_sha3beya/data/repositories/recipe_repository.dart';
import 'package:wasfa_sha3beya/features/dish_wheel/dish_wheel_page.dart';
import 'package:wasfa_sha3beya/features/home/home_page.dart';
import 'package:wasfa_sha3beya/features/spin_wheel/spin_wheel_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    DishWheelPage(),
    HomePage(),
    SizedBox.shrink(),
  ];

  void _openSpinWheel() async {
    final selectedCategory = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: Colors.grey.shade100,
          title: const Text(
            'اختر نوع الأكل',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          children: AppConstants.categories.map((cat) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pop(context, cat.name),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cat.color,
                          child: Icon(cat.icon, size: 18, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          cat.name,
                          style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );

    if (selectedCategory == null) return;
    if (!mounted) return;

    final repo = RecipeRepository();
    final allRecipes = await repo.getAll();
    final filteredRecipes = selectedCategory == AppConstants.categories.first.name
        ? allRecipes
        : allRecipes.where((r) => r.category.contains(selectedCategory)).toList();

    if (filteredRecipes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد وصفات لهذا القسم')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpinWheelPage(recipes: filteredRecipes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BannerAdWidget(),
            ConvexAppBar(
              style: TabStyle.reactCircle,
              backgroundColor: Colors.teal.shade800,
              activeColor: Colors.white,
              color: Colors.white70,
              elevation: 14,
              height: 64,
              items: const [
                TabItem(icon: Icons.food_bank_rounded, title: 'المواعين'),
                TabItem(icon: Icons.home_rounded, title: 'الوصفات'),
                TabItem(icon: Icons.restaurant_menu_rounded, title: 'عجلة الأكل'),
              ],
              initialActiveIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  _openSpinWheel();
                } else {
                  setState(() => _currentIndex = index);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
