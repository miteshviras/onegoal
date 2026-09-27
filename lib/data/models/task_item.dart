import 'dart:convert';

class TaskItem {
  final String id;
  final String? goalId;
  final String title;
  final String subtitle;
  final String scheduledTime;
  final int durationMinutes;
  final bool isCompleted;
  final bool isCurrentFocus;
  final int order;
  final int stepNumber;
  final int totalSteps;
  final String? completedAt;

  TaskItem({
    required this.id,
    this.goalId,
    required this.title,
    this.subtitle = '',
    required this.scheduledTime,
    this.durationMinutes = 25,
    this.isCompleted = false,
    this.isCurrentFocus = false,
    this.order = 0,
    this.stepNumber = 1,
    this.totalSteps = 5,
    this.completedAt,
  });

  TaskItem copyWith({
    String? id,
    String? goalId,
    String? title,
    String? subtitle,
    String? scheduledTime,
    int? durationMinutes,
    bool? isCompleted,
    bool? isCurrentFocus,
    int? order,
    int? stepNumber,
    int? totalSteps,
    String? completedAt,
  }) {
    return TaskItem(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompleted: isCompleted ?? this.isCompleted,
      isCurrentFocus: isCurrentFocus ?? this.isCurrentFocus,
      order: order ?? this.order,
      stepNumber: stepNumber ?? this.stepNumber,
      totalSteps: totalSteps ?? this.totalSteps,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goal_id': goalId,
      'title': title,
      'subtitle': subtitle,
      'scheduled_time': scheduledTime,
      'duration_minutes': durationMinutes,
      'is_completed': isCompleted,
      'is_current_focus': isCurrentFocus,
      'order': order,
      'step_number': stepNumber,
      'total_steps': totalSteps,
      'completed_at': completedAt,
    };
  }

  factory TaskItem.fromMap(Map<String, dynamic> map) {
    return TaskItem(
      id: map['id'] as String? ?? '',
      goalId: map['goal_id'] as String?,
      title: map['title'] as String? ?? '',
      subtitle: map['subtitle'] as String? ?? '',
      scheduledTime: map['scheduled_time'] as String? ?? '',
      durationMinutes: map['duration_minutes'] as int? ?? 25,
      isCompleted: map['is_completed'] as bool? ?? false,
      isCurrentFocus: map['is_current_focus'] as bool? ?? false,
      order: map['order'] as int? ?? 0,
      stepNumber: map['step_number'] as int? ?? 1,
      totalSteps: map['total_steps'] as int? ?? 5,
      completedAt: map['completed_at'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory TaskItem.fromJson(String source) =>
      TaskItem.fromMap(json.decode(source) as Map<String, dynamic>);
}
