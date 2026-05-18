import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasfa_sha3beya/data/models/dish_person.dart';

class DishRepository {
  static const String _storageKey = 'dish_people';
  static const String _customTasksKey = 'dish_custom_tasks';

  static Future<List<DishPerson>> loadPeople() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString(_storageKey);
      if (data == null) return [];
      final List decoded = jsonDecode(data);
      return decoded.map((e) => DishPerson.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading people: $e');
      return [];
    }
  }

  static Future<void> savePeople(List<DishPerson> people) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = jsonEncode(people.map((e) => e.toMap()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      debugPrint('Error saving people: $e');
    }
  }

  static Future<List<String>> loadCustomTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_customTasksKey) ?? [];
    } catch (e) {
      debugPrint('Error loading custom tasks: $e');
      return [];
    }
  }

  static Future<void> saveCustomTasks(List<String> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_customTasksKey, tasks);
    } catch (e) {
      debugPrint('Error saving custom tasks: $e');
    }
  }
}
