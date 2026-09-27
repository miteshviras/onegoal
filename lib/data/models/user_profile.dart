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

  final bool hasCompletedOnboarding;

  UserProfile({
    required this.id,
    required this.name,
    required this.title,
    required this.avatarUrl,
    this.streakDays = 0,
    this.level = 1,
    this.levelTitle = 'Mindful Beginner',
    this.score = 0,
    this.pointsToNextLevel = 50,
    this.evolutionProgress = 0.0,
    this.hasCompletedOnboarding = false,
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
    bool? hasCompletedOnboarding,
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
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
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
      'has_completed_onboarding': hasCompletedOnboarding,
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
      id: map['id'] as String? ?? 'user_default',
      name: map['name'] as String? ?? 'Seeker',
      title: map['title'] as String? ?? 'Intentional Builder',
      avatarUrl: map['avatar_url'] as String? ?? '',
      streakDays: map['streak_days'] as int? ?? 0,
      level: map['level'] as int? ?? 1,
      levelTitle: map['level_title'] as String? ?? 'Mindful Beginner',
      score: map['score'] as int? ?? 0,
      pointsToNextLevel: map['points_to_next_level'] as int? ?? 50,
      evolutionProgress:
          (map['evolution_progress'] as num?)?.toDouble() ?? 0.0,
      hasCompletedOnboarding:
          map['has_completed_onboarding'] as bool? ?? false,
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
