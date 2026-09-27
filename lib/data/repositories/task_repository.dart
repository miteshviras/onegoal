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
      final defaultTasks = _getDefaultTasks();
      await saveTasks(defaultTasks);
      return defaultTasks;
    }
    try {
      final List<dynamic> list = json.decode(raw);
      return list.map((e) => TaskItem.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return _getDefaultTasks();
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

  List<TaskItem> _getDefaultTasks() {
    return [
      TaskItem(
        id: 'task_1',
        goalId: 'goal_portfolio',
        title: 'Review hero copy & typography',
        subtitle: 'Refined headline values & font scales',
        scheduledTime: '09:00 AM',
        durationMinutes: 45,
        isCompleted: true,
        order: 1,
        stepNumber: 1,
        totalSteps: 5,
        completedAt: '9:30 AM',
      ),
      TaskItem(
        id: 'task_2',
        goalId: 'goal_portfolio',
        title: 'Export responsive imagery',
        subtitle: 'Optimized WebP assets for Retina display',
        scheduledTime: '11:00 AM',
        durationMinutes: 30,
        isCompleted: true,
        order: 2,
        stepNumber: 2,
        totalSteps: 5,
        completedAt: '11:15 AM',
      ),
      TaskItem(
        id: 'task_3',
        goalId: 'goal_portfolio',
        title: 'Deploy staging preview on Vercel',
        subtitle: 'Build hooks ready • DNS synced',
        scheduledTime: '01:30 PM',
        durationMinutes: 25,
        isCompleted: false,
        isCurrentFocus: true,
        order: 3,
        stepNumber: 3,
        totalSteps: 5,
      ),
      TaskItem(
        id: 'task_4',
        goalId: 'goal_portfolio',
        title: 'Connect custom domain DNS',
        subtitle: 'Configure CNAME and A records',
        scheduledTime: '02:00 PM',
        durationMinutes: 20,
        isCompleted: false,
        order: 4,
        stepNumber: 4,
        totalSteps: 5,
      ),
      TaskItem(
        id: 'task_5',
        goalId: 'goal_portfolio',
        title: 'Lighthouse audit & polish',
        subtitle: 'Target 95+ performance & accessibility',
        scheduledTime: '03:30 PM',
        durationMinutes: 30,
        isCompleted: false,
        order: 5,
        stepNumber: 5,
        totalSteps: 5,
      ),
    ];
  }
}
