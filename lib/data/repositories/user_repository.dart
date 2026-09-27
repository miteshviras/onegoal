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
        id: 'user_default',
        name: 'Seeker',
        title: 'Intentional Builder',
        avatarUrl: '',
        streakDays: 0,
        level: 1,
        levelTitle: 'Mindful Beginner',
        score: 0,
        pointsToNextLevel: 50,
        evolutionProgress: 0.0,
        hasCompletedOnboarding: false,
      );
      await saveUserProfile(defaultProfile);
      return defaultProfile;
    }
    try {
      return UserProfile.fromJson(raw);
    } catch (_) {
      return UserProfile(
        id: 'user_default',
        name: 'Seeker',
        title: 'Intentional Builder',
        avatarUrl: '',
        hasCompletedOnboarding: false,
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
