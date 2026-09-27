import 'dart:convert';

import '../../core/services/storage_service.dart';
import '../models/daily_reflection.dart';
import '../models/quiet_milestone.dart';

class ProgressRepository {
  final IStorageService _storageService;
  static const String _reflectionsKey = 'onegoal_reflections_data';
  static const String _milestonesKey = 'onegoal_badges_data';

  ProgressRepository(this._storageService);

  Future<List<DailyReflection>> getReflections() async {
    final raw = await _storageService.getString(_reflectionsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((e) => DailyReflection.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReflection(DailyReflection reflection) async {
    final list = await getReflections();
    // remove existing for same date if present
    list.removeWhere((r) => r.date == reflection.date);
    list.insert(0, reflection);
    final mapped = list.map((e) => e.toMap()).toList();
    await _storageService.saveString(_reflectionsKey, json.encode(mapped));
  }

  Future<List<QuietMilestone>> getMilestones() async {
    final raw = await _storageService.getString(_milestonesKey);
    if (raw == null || raw.isEmpty) {
      final defaultMilestones = _getDefaultMilestones();
      await saveMilestones(defaultMilestones);
      return defaultMilestones;
    }
    try {
      final List<dynamic> list = json.decode(raw);
      return list
          .map((e) => QuietMilestone.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getDefaultMilestones();
    }
  }

  Future<void> saveMilestones(List<QuietMilestone> milestones) async {
    final mapped = milestones.map((e) => e.toMap()).toList();
    await _storageService.saveString(_milestonesKey, json.encode(mapped));
  }

  List<QuietMilestone> _getDefaultMilestones() {
    return [
      QuietMilestone(
        id: 'badge_deep_work',
        title: 'Deep Work',
        subtitle: '10h+ uninterrupted',
        iconKey: 'psychology',
        isUnlocked: false,
      ),
      QuietMilestone(
        id: 'badge_5day_flow',
        title: '5-Day Flow',
        subtitle: 'Gentle continuity',
        iconKey: 'eco',
        isUnlocked: false,
      ),
      QuietMilestone(
        id: 'badge_clean_finish',
        title: 'Clean Finish',
        subtitle: 'Zero lingering tasks',
        iconKey: 'done_all',
        isUnlocked: false,
      ),
      QuietMilestone(
        id: 'badge_early_focus',
        title: 'Morning Clarity',
        subtitle: 'Started before 9 AM',
        iconKey: 'light_mode',
        isUnlocked: false,
      ),
      QuietMilestone(
        id: 'badge_evening_peace',
        title: 'Mindful Evening',
        subtitle: 'Completed 7 check-ins',
        iconKey: 'bedtime',
        isUnlocked: false,
      ),
      QuietMilestone(
        id: 'badge_calm_mastery',
        title: 'One Goal Master',
        subtitle: 'Completed high-priority milestone',
        iconKey: 'workspace_premium',
        isUnlocked: false,
      ),
    ];
  }
}
