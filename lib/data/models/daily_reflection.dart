import 'dart:convert';

class DailyReflection {
  final String id;
  final String date;
  final String mood; // 'great', 'balanced', 'tough'
  final String reflectionText;
  final bool completedRitual;
  final String createdAt;

  DailyReflection({
    required this.id,
    required this.date,
    required this.mood,
    this.reflectionText = '',
    this.completedRitual = true,
    required this.createdAt,
  });

  DailyReflection copyWith({
    String? id,
    String? date,
    String? mood,
    String? reflectionText,
    bool? completedRitual,
    String? createdAt,
  }) {
    return DailyReflection(
      id: id ?? this.id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      reflectionText: reflectionText ?? this.reflectionText,
      completedRitual: completedRitual ?? this.completedRitual,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'mood': mood,
      'reflection_text': reflectionText,
      'completed_ritual': completedRitual,
      'created_at': createdAt,
    };
  }

  factory DailyReflection.fromMap(Map<String, dynamic> map) {
    return DailyReflection(
      id: map['id'] as String? ?? '',
      date: map['date'] as String? ?? '',
      mood: map['mood'] as String? ?? 'great',
      reflectionText: map['reflection_text'] as String? ?? '',
      completedRitual: map['completed_ritual'] as bool? ?? false,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DailyReflection.fromJson(String source) =>
      DailyReflection.fromMap(json.decode(source) as Map<String, dynamic>);
}
