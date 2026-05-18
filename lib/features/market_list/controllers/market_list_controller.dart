import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wasfa_sha3beya/data/models/market_list_item.dart';

class MarketListController extends GetxController {
  final mondayItems = <MarketListItem>[].obs;
  final wednesdayItems = <MarketListItem>[].obs;
  final fridayItems = <MarketListItem>[].obs;

  static const _storageKey = 'market_list_v1';

  static const dayKeys = ['monday', 'wednesday', 'friday'];
  static const dayNames = ['الإثنين', 'الأربعاء', 'الجمعة'];

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  RxList<MarketListItem> itemsForDay(int tabIndex) {
    switch (tabIndex) {
      case 0: return mondayItems;
      case 1: return wednesdayItems;
      default: return fridayItems;
    }
  }

  String dayName(int tabIndex) => dayNames[tabIndex];
  String dayKey(int tabIndex) => dayKeys[tabIndex];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final data = jsonDecode(raw) as Map;
        mondayItems.value = _parseList(data['monday']);
        wednesdayItems.value = _parseList(data['wednesday']);
        fridayItems.value = _parseList(data['friday']);
      } catch (_) {
        // use empty
      }
    }
  }

  List<MarketListItem> _parseList(dynamic list) {
    if (list == null) return [];
    return (list as List)
        .map((e) => MarketListItem.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> addItem(int tabIndex, String text) async {
    final item = MarketListItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
    );
    switch (tabIndex) {
      case 0: mondayItems.add(item);
      case 1: wednesdayItems.add(item);
      default: fridayItems.add(item);
    }
    await _persist();
  }

  Future<void> toggleItem(int tabIndex, String itemId) async {
    final list = itemsForDay(tabIndex);
    final idx = list.indexWhere((e) => e.id == itemId);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(isChecked: !list[idx].isChecked);
    await _persist();
  }

  Future<void> deleteItem(int tabIndex, String itemId) async {
    final list = itemsForDay(tabIndex);
    list.removeWhere((e) => e.id == itemId);
    await _persist();
  }

  Future<void> updateItemText(int tabIndex, String itemId, String newText) async {
    final list = itemsForDay(tabIndex);
    final idx = list.indexWhere((e) => e.id == itemId);
    if (idx == -1) return;
    list[idx] = list[idx].copyWith(text: newText);
    await _persist();
  }

  Future<void> shareDayList(int tabIndex) async {
    final list = itemsForDay(tabIndex);
    final name = dayName(tabIndex);
    final buffer = StringBuffer();
    buffer.writeln('*طلبات سوق $name 🛒*');
    buffer.writeln('------------------------');
    if (list.isEmpty) {
      buffer.writeln('(قائمة فارغة)');
    } else {
      for (final item in list) {
        final mark = item.isChecked ? '✅' : '📌';
        buffer.writeln('$mark ${item.text}');
      }
    }
    buffer.writeln('------------------------');
    buffer.writeln('تم الإرسال عبر تطبيق الوصفات والملفات الذكية 🎡');
    await Share.share(buffer.toString());
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'monday': mondayItems.map((e) => e.toMap()).toList(),
      'wednesday': wednesdayItems.map((e) => e.toMap()).toList(),
      'friday': fridayItems.map((e) => e.toMap()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }
}
