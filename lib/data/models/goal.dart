import 'dart:convert';

class GoalMilestone {
  final String id;
  final String title;
  final bool isCompleted;
  final String? completedAt;

  GoalMilestone({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.completedAt,
  });

  GoalMilestone copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    String? completedAt,
  }) {
    return GoalMilestone(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
      'completed_at': completedAt,
    };
  }

  factory GoalMilestone.fromMap(Map<String, dynamic> map) {
    return GoalMilestone(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoalMilestone.fromJson(String source) =>
      GoalMilestone.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Goal {
  final String id;
  final String title;
  final String description;
  final String category;
  final int dueInDays;
  final double progress; // 0.0 to 1.0
  final bool isTodayMission;
  final int streakDays;
  final String affirmation;
  final String? imageUrl;
  final List<GoalMilestone> milestones;
  final bool isCompleted;
  final String? completedAt;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.dueInDays = 30,
    this.progress = 0.0,
    this.isTodayMission = false,
    this.streakDays = 0,
    this.affirmation = '',
    this.imageUrl,
    this.milestones = const [],
    this.isCompleted = false,
    this.completedAt,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? dueInDays,
    double? progress,
    bool? isTodayMission,
    int? streakDays,
    String? affirmation,
    String? imageUrl,
    List<GoalMilestone>? milestones,
    bool? isCompleted,
    String? completedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      dueInDays: dueInDays ?? this.dueInDays,
      progress: progress ?? this.progress,
      isTodayMission: isTodayMission ?? this.isTodayMission,
      streakDays: streakDays ?? this.streakDays,
      affirmation: affirmation ?? this.affirmation,
      imageUrl: imageUrl ?? this.imageUrl,
      milestones: milestones ?? this.milestones,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'due_in_days': dueInDays,
      'progress': progress,
      'is_today_mission': isTodayMission,
      'streak_days': streakDays,
      'affirmation': affirmation,
      'image_url': imageUrl,
      'milestones': milestones.map((x) => x.toMap()).toList(),
      'is_completed': isCompleted,
      'completed_at': completedAt,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      dueInDays: map['due_in_days'] as int? ?? 30,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
      isTodayMission: map['is_today_mission'] as bool? ?? false,
      streakDays: map['streak_days'] as int? ?? 0,
      affirmation: map['affirmation'] as String? ?? '',
      imageUrl: map['image_url'] as String?,
      milestones:
          (map['milestones'] as List<dynamic>?)
              ?.map((x) => GoalMilestone.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
      isCompleted: map['is_completed'] as bool? ?? false,
      completedAt: map['completed_at'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Goal.fromJson(String source) =>
      Goal.fromMap(json.decode(source) as Map<String, dynamic>);
}
