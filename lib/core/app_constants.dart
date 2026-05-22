import 'package:flutter/material.dart';

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryInfo(this.name, this.icon, this.color);
}

class AppConstants {
  static const String backgroundImage = 'assets/images/bk.png';
  static const String dishBackgroundImage = 'assets/images/bk1.png';

  static const List<CategoryInfo> categories = [
    CategoryInfo('كل الوصفات', Icons.menu_book_rounded, Colors.teal),
    CategoryInfo('حلويات', Icons.cake_rounded, Colors.pink),
    CategoryInfo('مشروبات', Icons.local_cafe_rounded, Colors.brown),
    CategoryInfo('محاشي', Icons.restaurant_rounded, Colors.green),
    CategoryInfo('شوربة', Icons.soup_kitchen_rounded, Colors.redAccent),
    CategoryInfo('مشاوي', Icons.local_fire_department_rounded, Colors.deepOrange),
    CategoryInfo('أكلات عيد الأضحى', Icons.celebration_rounded, Color(0xFFD4A017)),
  ];
}
