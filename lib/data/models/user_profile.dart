import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final String title;
  final String avatarUrl;
  final int streakDays;
  final int level;
  final String levelTitle;
  final int score;
  final int pointsToNextLevel;
  final double evolutionProgress;
  
  // Settings
  final bool missionLockEnabled;
  final bool calmNotificationsEnabled;
  final String eveningRitualTime;
  final int focusTimerMinutes;
  final bool adaptivePacingEnabled;
  final String coachingTone; // 'gentle' | 'concise'
  final String themeMode; // 'dark' | 'light' | 'system'
  final String hapticsMode; // 'soft' | 'crisp' | 'off'

  UserProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    this.streakDays = 28,
    this.level = 4,
    this.levelTitle = 'Consistency Builder',
    this.score = 92,
    this.pointsToNextLevel = 8,
    this.evolutionProgress = 0.82,
    this.missionLockEnabled = true,
    this.calmNotificationsEnabled = true,
    this.eveningRitualTime = '8:30 PM',
    this.focusTimerMinutes = 25,
    this.adaptivePacingEnabled = true,
    this.coachingTone = 'gentle',
    this.themeMode = 'dark',
    this.hapticsMode = 'soft',
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? title,
    String? avatarUrl,
    int? streakDays,
    int? level,
    String? levelTitle,
    int? score,
    int? pointsToNextLevel,
    double? evolutionProgress,
    bool? missionLockEnabled,
    bool? calmNotificationsEnabled,
    String? eveningRitualTime,
    int? focusTimerMinutes,
    bool? adaptivePacingEnabled,
    String? coachingTone,
    String? themeMode,
    String? hapticsMode,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      score: score ?? this.score,
      pointsToNextLevel: pointsToNextLevel ?? this.pointsToNextLevel,
      evolutionProgress: evolutionProgress ?? this.evolutionProgress,
      missionLockEnabled: missionLockEnabled ?? this.missionLockEnabled,
      calmNotificationsEnabled:
          calmNotificationsEnabled ?? this.calmNotificationsEnabled,
      eveningRitualTime: eveningRitualTime ?? this.eveningRitualTime,
      focusTimerMinutes: focusTimerMinutes ?? this.focusTimerMinutes,
      adaptivePacingEnabled: adaptivePacingEnabled ?? this.adaptivePacingEnabled,
      coachingTone: coachingTone ?? this.coachingTone,
      themeMode: themeMode ?? this.themeMode,
      hapticsMode: hapticsMode ?? this.hapticsMode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'avatar_url': avatarUrl,
      'streak_days': streakDays,
      'level': level,
      'level_title': levelTitle,
      'score': score,
      'points_to_next_level': pointsToNextLevel,
      'evolution_progress': evolutionProgress,
      'mission_lock_enabled': missionLockEnabled,
      'calm_notifications_enabled': calmNotificationsEnabled,
      'evening_ritual_time': eveningRitualTime,
      'focus_timer_minutes': focusTimerMinutes,
      'adaptive_pacing_enabled': adaptivePacingEnabled,
      'coaching_tone': coachingTone,
      'theme_mode': themeMode,
      'haptics_mode': hapticsMode,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String? ?? 'user_1',
      name: map['name'] as String? ?? 'Sarah Jenkins',
      title: map['title'] as String? ?? 'Product Designer & Independent Builder',
      avatarUrl: map['avatar_url'] as String? ?? '',
      streakDays: map['streak_days'] as int? ?? 28,
      level: map['level'] as int? ?? 4,
      levelTitle: map['level_title'] as String? ?? 'Consistency Builder',
      score: map['score'] as int? ?? 92,
      pointsToNextLevel: map['points_to_next_level'] as int? ?? 8,
      evolutionProgress:
          (map['evolution_progress'] as num?)?.toDouble() ?? 0.82,
      missionLockEnabled: map['mission_lock_enabled'] as bool? ?? true,
      calmNotificationsEnabled:
          map['calm_notifications_enabled'] as bool? ?? true,
      eveningRitualTime: map['evening_ritual_time'] as String? ?? '8:30 PM',
      focusTimerMinutes: map['focus_timer_minutes'] as int? ?? 25,
      adaptivePacingEnabled: map['adaptive_pacing_enabled'] as bool? ?? true,
      coachingTone: map['coaching_tone'] as String? ?? 'gentle',
      themeMode: map['theme_mode'] as String? ?? 'dark',
      hapticsMode: map['haptics_mode'] as String? ?? 'soft',
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
