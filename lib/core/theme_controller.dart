import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();
  static const String _themeKey = 'theme_index';

  final RxInt _themeIndex = 0.obs;

  int get themeIndex => _themeIndex.value;

  ThemeData get currentTheme =>
      _themeIndex.value == 0 ? AppTheme.midnightRoseTheme : AppTheme.tealTheme;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _themeIndex.value = prefs.getInt(_themeKey) ?? 0;
  }

  void switchTheme(int index) {
    _themeIndex.value = index;
    Get.changeTheme(currentTheme);
    SharedPreferences.getInstance().then(
      (prefs) => prefs.setInt(_themeKey, index),
    );
  }
}
