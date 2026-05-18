import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wasfa_sha3beya/data/models/child_profile.dart';
import 'package:wasfa_sha3beya/data/models/timetable_entry.dart';

class TimetableController extends GetxController {
  final profiles = <ChildProfile>[].obs;
  final selectedProfileId = Rxn<String>();
  final selectedDay = 0.obs;

  static const _storageKey = 'timetable_profiles_v2';

  ChildProfile? get selectedProfile =>
      profiles.firstWhereOrNull((p) => p.id == selectedProfileId.value);

  List<TimetableEntry> get entriesForSelectedDay {
    final p = selectedProfile;
    if (p == null) return [];
    return p.entries.where((e) => e.day == selectedDay.value).toList();
  }

  static const defaultSubjects = [
    ('عربي', 0, '08:00', '08:45', 0xFFE53935),
    ('إنجليزي', 1, '08:00', '08:45', 0xFF1E88E5),
    ('رياضيات', 2, '08:00', '08:45', 0xFF43A047),
    ('علوم', 3, '08:00', '08:45', 0xFFFB8C00),
    ('دراسات', 4, '08:00', '08:45', 0xFF8E24AA),
  ];

  static const subjectColors = [
    0xFFE53935, 0xFF1E88E5, 0xFF43A047, 0xFFFB8C00, 0xFF8E24AA,
    0xFF00ACC1, 0xFFF4511E, 0xFF3949AB, 0xFFC0CA33, 0xFF6D4C41,
  ];

  int _colorIndex = 0;

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
        final list = (data['profiles'] as List)
            .map((e) => ChildProfile.fromMap(e as Map<String, dynamic>))
            .toList();
        profiles.value = list;
        final selId = data['selectedProfileId'] as String?;
        if (selId != null && list.any((p) => p.id == selId)) {
          selectedProfileId.value = selId;
        } else if (list.isNotEmpty) {
          selectedProfileId.value = list.first.id;
        }
      } catch (_) {
        await _seedDefaultProfile();
      }
    } else {
      await _seedDefaultProfile();
    }
  }

  Future<void> _seedDefaultProfile() async {
    final entries = defaultSubjects.mapIndexed((i, s) => TimetableEntry(
          id: 'default_$i',
          subjectName: s.$1,
          day: s.$2,
          startTime: s.$3,
          endTime: s.$4,
          colorValue: s.$5,
        )).toList();
    final profile = ChildProfile(
      id: 'default_profile',
      name: 'طفلي',
      entries: entries,
    );
    profiles.value = [profile];
    selectedProfileId.value = profile.id;
    await _persist();
  }

  Future<void> addProfile(String name) async {
    final profile = ChildProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
    profiles.add(profile);
    selectedProfileId.value = profile.id;
    await _persist();
  }

  Future<void> deleteProfile(String id) async {
    profiles.removeWhere((p) => p.id == id);
    if (profiles.isEmpty) {
      selectedProfileId.value = null;
    } else if (selectedProfileId.value == id) {
      selectedProfileId.value = profiles.first.id;
    }
    await _persist();
  }

  void selectProfile(String id) {
    if (profiles.any((p) => p.id == id)) {
      selectedProfileId.value = id;
    }
  }

  Future<void> addEntry({
    required String profileId,
    required String subjectName,
    required int day,
    required String startTime,
    required String endTime,
  }) async {
    final idx = profiles.indexWhere((p) => p.id == profileId);
    if (idx == -1) return;
    final entry = TimetableEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      subjectName: subjectName,
      day: day,
      startTime: startTime,
      endTime: endTime,
      colorValue: _nextColor(),
    );
    final updated = profiles[idx].copyWith(
      entries: [...profiles[idx].entries, entry],
    );
    profiles[idx] = updated;
    await _persist();
  }

  Future<void> updateEntry({
    required String profileId,
    required String entryId,
    required String subjectName,
    required int day,
    required String startTime,
    required String endTime,
  }) async {
    final idx = profiles.indexWhere((p) => p.id == profileId);
    if (idx == -1) return;
    final entryIdx = profiles[idx].entries.indexWhere((e) => e.id == entryId);
    if (entryIdx == -1) return;
    final old = profiles[idx].entries[entryIdx];
    final updated = profiles[idx].copyWith(
      entries: [
        ...profiles[idx].entries.sublist(0, entryIdx),
        old.copyWith(
          subjectName: subjectName,
          day: day,
          startTime: startTime,
          endTime: endTime,
        ),
        ...profiles[idx].entries.sublist(entryIdx + 1),
      ],
    );
    profiles[idx] = updated;
    await _persist();
  }

  Future<void> deleteEntry(String profileId, String entryId) async {
    final idx = profiles.indexWhere((p) => p.id == profileId);
    if (idx == -1) return;
    final updated = profiles[idx].copyWith(
      entries: profiles[idx].entries.where((e) => e.id != entryId).toList(),
    );
    profiles[idx] = updated;
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'profiles': profiles.map((p) => p.toMap()).toList(),
      'selectedProfileId': selectedProfileId.value,
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  int _nextColor() {
    final c = subjectColors[_colorIndex % subjectColors.length];
    _colorIndex++;
    return c;
  }
}

extension _IndexedIterable<E> on Iterable<E> {
  List<T> mapIndexed<T>(T Function(int index, E element) f) {
    var i = 0;
    return map((e) => f(i++, e)).toList();
  }
}
