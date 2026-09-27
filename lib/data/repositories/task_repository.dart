import 'dart:convert';
import '../../core/services/storage_service.dart';
import '../models/task_item.dart';

class TaskRepository {
  final IStorageService _storageService;
  static const String _storageKey = 'onegoal_tasks_data';

  TaskRepository(this._storageService);

  Future<List<TaskItem>> getTasks() async {
    final raw = await _storageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => TaskItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((e) => e.toMap()).toList();
    await _storageService.saveString(_storageKey, json.encode(list));
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final tasks = await getTasks();
    final index = tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      final t = tasks[index];
      tasks[index] = t.copyWith(
        isCompleted: !t.isCompleted,
        completedAt: !t.isCompleted ? DateTime.now().toIso8601String() : null,
      );
      await saveTasks(tasks);
    }
  }

  Future<void> addTask(TaskItem task) async {
    final tasks = await getTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> deleteTask(String taskId) async {
    final tasks = await getTasks();
    tasks.removeWhere((t) => t.id == taskId);
    // Recalculate step numbers and total steps
    for (int i = 0; i < tasks.length; i++) {
      tasks[i] = tasks[i].copyWith(
        stepNumber: i + 1,
        totalSteps: tasks.length,
        order: i + 1,
      );
    }
    await saveTasks(tasks);
  }

  Future<void> setFocusTask(String taskId) async {
    final tasks = await getTasks();
    for (int i = 0; i < tasks.length; i++) {
      tasks[i] = tasks[i].copyWith(
        isCurrentFocus: tasks[i].id == taskId,
      );
    }
    await saveTasks(tasks);
  }
}

