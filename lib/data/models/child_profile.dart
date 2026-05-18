import 'package:wasfa_sha3beya/data/models/timetable_entry.dart';

class ChildProfile {
  final String id;
  final String name;
  final List<TimetableEntry> entries;

  ChildProfile({
    required this.id,
    required this.name,
    List<TimetableEntry>? entries,
  }) : entries = entries ?? [];

  ChildProfile copyWith({
    String? id,
    String? name,
    List<TimetableEntry>? entries,
  }) =>
      ChildProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        entries: entries ?? this.entries,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'entries': entries.map((e) => e.toMap()).toList(),
      };

  factory ChildProfile.fromMap(Map<String, dynamic> m) => ChildProfile(
        id: m['id'] as String,
        name: m['name'] as String,
        entries: (m['entries'] as List?)
                ?.map(
                    (e) => TimetableEntry.fromMap(e as Map<String, dynamic>))
                .toList() ??
            [],
      );
}
