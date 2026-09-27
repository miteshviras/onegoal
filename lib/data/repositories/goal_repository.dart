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
      return [];
    }
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => Goal.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
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

  Future<void> deleteGoal(String goalId) async {
    final current = await getGoals();
    current.removeWhere((g) => g.id == goalId);
    await saveGoals(current);
  }
}

