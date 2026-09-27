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
}
