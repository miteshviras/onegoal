import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../models/goal.dart';

class GoalRepository {
  final IStorageService _storageService;
  static const String _storageKey = 'onegoal_goals_data';

  GoalRepository(this._storageService);

  Future<List<Goal>> getGoals() async {
    final raw = await _storageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      final defaultGoals = _getDefaultGoals();
      await saveGoals(defaultGoals);
      return defaultGoals;
    }
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => Goal.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getDefaultGoals();
    }
  }

  Future<void> saveGoals(List<Goal> goals) async {
    final list = goals.map((e) => e.toMap()).toList();
    await _storageService.saveString(_storageKey, json.encode(list));
  }

  Future<void> addGoal(Goal goal) async {
    final current = await getGoals();
    current.add(goal);
    await saveGoals(current);
  }

  Future<void> updateGoal(Goal goal) async {
    final current = await getGoals();
    final index = current.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      current[index] = goal;
      await saveGoals(current);
    }
  }

  Future<void> setTodayMission(String goalId) async {
    final current = await getGoals();
    final updated = current.map((g) {
      if (g.id == goalId) {
        return g.copyWith(isTodayMission: true);
      } else {
        return g.copyWith(isTodayMission: false);
      }
    }).toList();
    await saveGoals(updated);
  }

  List<Goal> _getDefaultGoals() {
    return [
      Goal(
        id: 'goal_portfolio',
        title: 'Ship Portfolio Website',
        description:
            'A crafted digital home showing 4 marquee case studies and design philosophy.',
        category: 'Career & Craft',
        dueInDays: 12,
        progress: 0.68,
        isTodayMission: true,
        streakDays: 6,
        affirmation: 'You are becoming someone who finishes what they start.',
        imageUrl:
            'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=800&q=80',
        milestones: [
          GoalMilestone(
            id: 'm1',
            title: 'Review hero copy & typography',
            isCompleted: true,
            completedAt: 'Oct 24',
          ),
          GoalMilestone(
            id: 'm2',
            title: 'Export responsive imagery & assets',
            isCompleted: true,
            completedAt: 'Oct 24',
          ),
          GoalMilestone(
            id: 'm3',
            title: 'Deploy staging preview on Vercel',
            isCompleted: false,
          ),
          GoalMilestone(
            id: 'm4',
            title: 'Connect custom domain DNS & SSL',
            isCompleted: false,
          ),
          GoalMilestone(
            id: 'm5',
            title: 'Lighthouse audit & 100% accessibility score',
            isCompleted: false,
          ),
        ],
      ),
      Goal(
        id: 'goal_run',
        title: 'Morning 5km Run Routine',
        description: 'Consistent aerobic base and mindfulness outdoor runs.',
        category: 'Health & Energy',
        dueInDays: 45,
        progress: 0.80,
        isTodayMission: false,
        streakDays: 14,
        affirmation: "You're becoming someone who never skips workouts.",
        imageUrl:
            'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?auto=format&fit=crop&w=800&q=80',
        milestones: [
          GoalMilestone(
            id: 'rm1',
            title: 'Session 1: 5.2km zone 2 pace',
            isCompleted: true,
            completedAt: 'Oct 20',
          ),
          GoalMilestone(
            id: 'rm2',
            title: 'Session 2: 5.0km sunrise tempo',
            isCompleted: true,
            completedAt: 'Oct 22',
          ),
          GoalMilestone(
            id: 'rm3',
            title: 'Session 3: 5.4km river loop',
            isCompleted: true,
            completedAt: 'Oct 23',
          ),
          GoalMilestone(
            id: 'rm4',
            title: 'Session 4: 5.1km recovery stride',
            isCompleted: true,
            completedAt: 'Oct 24',
          ),
          GoalMilestone(
            id: 'rm5',
            title: 'Session 5: 6.0km weekend endurance',
            isCompleted: false,
          ),
        ],
      ),
      // Completed goals for the archive accordion
      Goal(
        id: 'goal_atomic_habits',
        title: "Read 'Atomic Habits'",
        description: 'Read and highlighted James Clear classic.',
        category: 'Mindset',
        dueInDays: 0,
        progress: 1.0,
        isCompleted: true,
        completedAt: 'Finished on Oct 14',
      ),
      Goal(
        id: 'goal_tax_prep',
        title: 'Q3 Tax Audit Prep',
        description: 'Organized accounting receipts and deductions.',
        category: 'Finance',
        dueInDays: 0,
        progress: 1.0,
        isCompleted: true,
        completedAt: 'Finished on Oct 03',
      ),
    ];
  }
}
