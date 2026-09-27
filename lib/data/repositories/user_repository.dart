import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../models/user_profile.dart';

class UserRepository {
  final IStorageService _storageService;
  static const String _storageKey = 'onegoal_user_profile';

  UserRepository(this._storageService);

  Future<UserProfile> getUserProfile() async {
    final raw = await _storageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final defaultProfile = UserProfile(
        id: 'user_sarah',
        name: 'Sarah Jenkins',
        title: 'Product Designer & Independent Builder',
        avatarUrl:
            'https://lh3.googleusercontent.com/aida/AEtjO1VyfNg2OaVvHBP8RL2yVF9oxMg9AdfQV0V_uaoHNRIR-Q4EThU73ZbuyayHQ0OW0KMyfiZDFA16CmJeTx9kTN3eOKF__njdZJUveEWeXz_atJHyX1uqAvK8rlQmbCMIhVBKKSxUtSJ828R3RFZD3NlDpnkvXkCa2zJjZ_6IEW5oO7eM269JiI6XqGqI2XLQZVD0Tsq8Hi028hDYsQfRmEgMomBFdUtWWYJZF0QLgLR3XCtLI5zv5TeNrs34',
        streakDays: 28,
        level: 4,
        levelTitle: 'Consistency Builder',
        score: 92,
        pointsToNextLevel: 8,
        evolutionProgress: 0.82,
        missionLockEnabled: true,
        calmNotificationsEnabled: true,
        eveningRitualTime: '8:30 PM',
        focusTimerMinutes: 25,
        adaptivePacingEnabled: true,
        coachingTone: 'gentle',
        themeMode: 'dark',
        hapticsMode: 'soft',
      );
      await saveUserProfile(defaultProfile);
      return defaultProfile;
    }
    try {
      return UserProfile.fromJson(raw);
    } catch (_) {
      return UserProfile(
        id: 'user_sarah',
        name: 'Sarah Jenkins',
        title: 'Product Designer & Independent Builder',
        avatarUrl: '',
      );
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _storageService.saveString(_storageKey, profile.toJson());
  }

  Future<void> clearAllData() async {
    await _storageService.clear();
  }
}
