import 'package:flutter/material.dart';

class TimetableEntry {
  final String id;
  final String subjectName;
  final int day;
  final String startTime;
  final String endTime;
  final int colorValue;

  TimetableEntry({
    required this.id,
    required this.subjectName,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.colorValue = 0xFF00897B,
  });

  Color get color => Color(colorValue);

  TimetableEntry copyWith({
    String? id,
    String? subjectName,
    int? day,
    String? startTime,
    String? endTime,
    int? colorValue,
  }) =>
      TimetableEntry(
        id: id ?? this.id,
        subjectName: subjectName ?? this.subjectName,
        day: day ?? this.day,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        colorValue: colorValue ?? this.colorValue,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'subjectName': subjectName,
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
        'colorValue': colorValue,
      };

  factory TimetableEntry.fromMap(Map<String, dynamic> m) => TimetableEntry(
        id: m['id'] as String,
        subjectName: m['subjectName'] as String,
        day: m['day'] as int,
        startTime: m['startTime'] as String,
        endTime: m['endTime'] as String,
        colorValue: m['colorValue'] as int? ?? 0xFF00897B,
      );
}
