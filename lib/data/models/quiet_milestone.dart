import 'dart:convert';

class QuietMilestone {
  final String id;
  final String title;
  final String subtitle;
  final String iconKey; // 'psychology', 'eco', 'done_all', 'bolt', etc.
  final bool isUnlocked;
  final String? unlockedDate;

  QuietMilestone({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  QuietMilestone copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? iconKey,
    bool? isUnlocked,
    String? unlockedDate,
  }) {
    return QuietMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconKey: iconKey ?? this.iconKey,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedDate: unlockedDate ?? this.unlockedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'icon_key': iconKey,
      'is_unlocked': isUnlocked,
      'unlocked_date': unlockedDate,
    };
  }

  factory QuietMilestone.fromMap(Map<String, dynamic> map) {
    return QuietMilestone(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      iconKey: map['icon_key'] as String? ?? 'verified',
      isUnlocked: map['is_unlocked'] as bool? ?? false,
      unlockedDate: map['unlocked_date'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuietMilestone.fromJson(String source) =>
      QuietMilestone.fromMap(json.decode(source) as Map<String, dynamic>);
}
