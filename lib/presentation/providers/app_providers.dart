import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/lockscreen_timer_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/goal.dart';
import '../../data/models/task_item.dart';
import '../../data/models/daily_reflection.dart';
import '../../data/models/quiet_milestone.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/progress_repository.dart';
import '../../data/repositories/user_repository.dart';

// --- Base Services Providers ---
final storageServiceProvider = Provider<IStorageService>((ref) {
  return LocalStorageService();
});

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return GoalRepository(storage);
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return TaskRepository(storage);
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProgressRepository(storage);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserRepository(storage);
});

// --- Goals State & Notifier (Riverpod 3 Notifier) ---
class GoalsState {
  final List<Goal> goals;
  final bool isLoading;

  GoalsState({this.goals = const [], this.isLoading = true});

  Goal? get todayMission {
    final list = goals
        .where((g) => g.isTodayMission && !g.isCompleted)
        .toList();
    if (list.isNotEmpty) return list.first;
    return null;
  }

  List<Goal> get activeGoals => goals.where((g) => !g.isCompleted).toList();
  List<Goal> get completedGoals => goals.where((g) => g.isCompleted).toList();

  GoalsState copyWith({List<Goal>? goals, bool? isLoading}) {
    return GoalsState(
      goals: goals ?? this.goals,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class GoalsNotifier extends Notifier<GoalsState> {
  GoalRepository get _repo => ref.read(goalRepositoryProvider);

  @override
  GoalsState build() {
    Future.microtask(loadGoals);
    return GoalsState();
  }

  Future<void> loadGoals() async {
    state = state.copyWith(isLoading: true);
    final goals = await _repo.getGoals();
    state = state.copyWith(goals: goals, isLoading: false);
  }

  Future<void> setTodayMission(String goalId) async {
    await _repo.setTodayMission(goalId);
    await loadGoals();
  }

  Future<void> deleteGoal(String goalId) async {
    await _repo.deleteGoal(goalId);
    await loadGoals();
  }

  Future<void> archiveGoal(String goalId) async {
    final currentGoals = [...state.goals];
    final gIdx = currentGoals.indexWhere((g) => g.id == goalId);
    if (gIdx == -1) return;
    final updated = currentGoals[gIdx].copyWith(
      isCompleted: true,
      completedAt: DateTime.now().toIso8601String(),
    );
    currentGoals[gIdx] = updated;
    state = state.copyWith(goals: currentGoals);
    await _repo.saveGoals(currentGoals);
  }

  Future<void> completeGoal(String goalId) async {
    final currentGoals = [...state.goals];
    final gIdx = currentGoals.indexWhere((g) => g.id == goalId);
    if (gIdx == -1) return;
    final allMilestonesCompleted = currentGoals[gIdx].milestones
        .map((m) => m.copyWith(isCompleted: true))
        .toList();
    final updated = currentGoals[gIdx].copyWith(
      isCompleted: true,
      progress: 1.0,
      completedAt: DateTime.now().toIso8601String(),
      milestones: allMilestonesCompleted,
    );
    currentGoals[gIdx] = updated;
    state = state.copyWith(goals: currentGoals);
    await _repo.saveGoals(currentGoals);
  }

  Future<void> toggleMilestone(String goalId, String milestoneId) async {
    final currentGoals = [...state.goals];
    final gIdx = currentGoals.indexWhere((g) => g.id == goalId);
    if (gIdx == -1) return;

    final goal = currentGoals[gIdx];
    final updatedMilestones = goal.milestones.map((m) {
      if (m.id == milestoneId) {
        return m.copyWith(isCompleted: !m.isCompleted);
      }
      return m;
    }).toList();

    final completedCount = updatedMilestones.where((m) => m.isCompleted).length;
    final total = updatedMilestones.isEmpty ? 1 : updatedMilestones.length;
    final newProgress = completedCount / total;

    final updatedGoal = goal.copyWith(
      milestones: updatedMilestones,
      progress: newProgress,
      isCompleted: completedCount == total && total > 0,
    );

    currentGoals[gIdx] = updatedGoal;
    state = state.copyWith(goals: currentGoals);
    await _repo.saveGoals(currentGoals);
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required String category,
    required int dueInDays,
    required String affirmation,
    String? imageUrl,
    List<String> milestoneTitles = const [],
  }) async {
    final uuid = const Uuid();
    final newGoal = Goal(
      id: 'goal_${uuid.v4().substring(0, 8)}',
      title: title,
      description: description,
      category: category,
      dueInDays: dueInDays,
      affirmation: affirmation,
      imageUrl: imageUrl ?? 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?auto=format&fit=crop&w=800&q=80',
      milestones: milestoneTitles
          .map((m) => GoalMilestone(id: uuid.v4().substring(0, 8), title: m))
          .toList(),
    );
    await _repo.addGoal(newGoal);
    await loadGoals();
  }
}

final goalsNotifierProvider = NotifierProvider<GoalsNotifier, GoalsState>(
  GoalsNotifier.new,
);

// --- Tasks State & Notifier ---
class TasksState {
  final List<TaskItem> tasks;
  final bool isLoading;

  TasksState({this.tasks = const [], this.isLoading = true});

  TaskItem? get inFocusTask {
    final active = tasks
        .where((t) => t.isCurrentFocus && !t.isCompleted)
        .toList();
    if (active.isNotEmpty) return active.first;
    final remaining = tasks.where((t) => !t.isCompleted).toList();
    return remaining.isNotEmpty ? remaining.first : null;
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get totalCount => tasks.length;
  int get remainingCount => tasks.where((t) => !t.isCompleted).length;

  TasksState copyWith({List<TaskItem>? tasks, bool? isLoading}) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TasksNotifier extends Notifier<TasksState> {
  TaskRepository get _repo => ref.read(taskRepositoryProvider);

  @override
  TasksState build() {
    Future.microtask(loadTasks);
    return TasksState();
  }

  Future<void> loadTasks() async {
    state = state.copyWith(isLoading: true);
    final tasks = await _repo.getTasks();
    state = state.copyWith(tasks: tasks, isLoading: false);
    final inFocus = state.inFocusTask;
    if (inFocus != null) {
      LockscreenTimerService().updateActiveTask(
        taskTitle: inFocus.title,
        subtitle: inFocus.subtitle,
        durationMinutes: inFocus.durationMinutes,
      );
    }
    LockscreenTimerService().syncDailyTasks(tasks);
  }

  Future<void> toggleTask(String taskId) async {
    await _repo.toggleTaskCompletion(taskId);
    await loadTasks();
  }

  Future<void> setFocusTask(String taskId) async {
    await _repo.setFocusTask(taskId);
    await loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _repo.deleteTask(taskId);
    await loadTasks();
  }

  Future<void> addTask({
    required String title,
    required String subtitle,
    required String scheduledTime,
    int durationMinutes = 25,
    String? goalId,
    bool isCurrentFocus = false,
  }) async {
    final uuid = const Uuid();
    final newLength = state.tasks.length + 1;
    final newTask = TaskItem(
      id: 'task_${uuid.v4().substring(0, 8)}',
      goalId: goalId,
      title: title,
      subtitle: subtitle,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      isCurrentFocus: isCurrentFocus || state.tasks.isEmpty,
      order: newLength,
      stepNumber: newLength,
      totalSteps: newLength,
    );
    await _repo.addTask(newTask);
    await loadTasks();
  }
}

final tasksNotifierProvider = NotifierProvider<TasksNotifier, TasksState>(
  TasksNotifier.new,
);

// --- Focus Timer State & Notifier ---
enum TimerStatus { initial, running, paused, completed }

class FocusTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final TimerStatus status;
  final String taskTitle;
  final String subtitle;

  FocusTimerState({
    this.totalSeconds = 25 * 60,
    this.remainingSeconds = 25 * 60,
    this.status = TimerStatus.initial,
    this.taskTitle = 'Add your first focus step',
    this.subtitle = 'Break down your goal into calm micro-steps',
  });

  String get formattedTime {
    final hours = remainingSeconds ~/ 3600;
    final mins = (remainingSeconds % 3600) ~/ 60;
    final secs = remainingSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double get progress =>
      totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    TimerStatus? status,
    String? taskTitle,
    String? subtitle,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      taskTitle: taskTitle ?? this.taskTitle,
      subtitle: subtitle ?? this.subtitle,
    );
  }
}

class FocusTimerNotifier extends Notifier<FocusTimerState> {
  Timer? _timer;
  LockscreenActionCallback? _lockscreenCallback;

  @override
  FocusTimerState build() {
    _lockscreenCallback = (action) {
      if (action == 'pause') {
        pause();
      } else if (action == 'resume') {
        startOrResume();
      } else if (action == 'complete') {
        pause();
        final currentInFocus = ref.read(tasksNotifierProvider).inFocusTask;
        if (currentInFocus != null) {
          ref
              .read(tasksNotifierProvider.notifier)
              .toggleTask(currentInFocus.id);
        }
      }
    };

    LockscreenTimerService().addListener(_lockscreenCallback!);

    ref.onDispose(() {
      _timer?.cancel();
      if (_lockscreenCallback != null) {
        LockscreenTimerService().removeListener(_lockscreenCallback!);
      }
    });
    return FocusTimerState();
  }

  void setTaskAndDuration(String title, int minutes, {String subtitle = ''}) {
    _timer?.cancel();
    state = FocusTimerState(
      totalSeconds: minutes * 60,
      remainingSeconds: minutes * 60,
      status: TimerStatus.initial,
      taskTitle: title,
      subtitle: subtitle,
    );
    LockscreenTimerService().updateActiveTask(
      taskTitle: title,
      subtitle: subtitle,
      durationMinutes: minutes,
    );
  }

  void setDuration(int minutes) {
    setTaskAndDuration(state.taskTitle, minutes, subtitle: state.subtitle);
  }

  void startOrResume() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);
    LockscreenTimerService().startTimer(
      taskTitle: state.taskTitle,
      subtitle: state.subtitle,
      remainingSeconds: state.remainingSeconds,
      totalSeconds: state.totalSeconds,
    );

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(status: TimerStatus.completed);
        LockscreenTimerService().stopTimer();
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
    LockscreenTimerService().pauseTimer(
      taskTitle: state.taskTitle,
      subtitle: state.subtitle,
      remainingSeconds: state.remainingSeconds,
    );
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      remainingSeconds: state.totalSeconds,
      status: TimerStatus.initial,
    );
    LockscreenTimerService().stopTimer();
  }
}

final focusTimerNotifierProvider =
    NotifierProvider<FocusTimerNotifier, FocusTimerState>(
      FocusTimerNotifier.new,
    );

// --- Progress & Reflection State & Notifier ---
class ProgressState {
  final List<QuietMilestone> milestones;
  final List<DailyReflection> reflections;
  final bool isLoading;
  final double harmonyScore;
  final double missionsProgress;
  final double habitsProgress;
  final double focusHoursProgress;
  final double focusHours;

  ProgressState({
    this.milestones = const [],
    this.reflections = const [],
    this.isLoading = true,
    this.harmonyScore = 0.84,
    this.missionsProgress = 0.84,
    this.habitsProgress = 0.85,
    this.focusHoursProgress = 0.75,
    this.focusHours = 14.5,
  });

  String get formattedFocusHours {
    if (focusHours == 0) return '0';
    if (focusHours == focusHours.truncateToDouble()) {
      return focusHours.toInt().toString();
    }
    return focusHours.toStringAsFixed(1);
  }

  ProgressState copyWith({
    List<QuietMilestone>? milestones,
    List<DailyReflection>? reflections,
    bool? isLoading,
    double? harmonyScore,
    double? missionsProgress,
    double? habitsProgress,
    double? focusHoursProgress,
    double? focusHours,
  }) {
    return ProgressState(
      milestones: milestones ?? this.milestones,
      reflections: reflections ?? this.reflections,
      isLoading: isLoading ?? this.isLoading,
      harmonyScore: harmonyScore ?? this.harmonyScore,
      missionsProgress: missionsProgress ?? this.missionsProgress,
      habitsProgress: habitsProgress ?? this.habitsProgress,
      focusHoursProgress: focusHoursProgress ?? this.focusHoursProgress,
      focusHours: focusHours ?? this.focusHours,
    );
  }
}

class ProgressNotifier extends Notifier<ProgressState> {
  ProgressRepository get _repo => ref.read(progressRepositoryProvider);

  @override
  ProgressState build() {
    Future.microtask(loadProgress);
    return ProgressState();
  }

  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true);
    var milestones = await _repo.getMilestones();
    final reflections = await _repo.getReflections();
    final tasks = await ref.read(taskRepositoryProvider).getTasks();
    final goals = await ref.read(goalRepositoryProvider).getGoals();

    // Calculate real focus hours
    final completedTasks = tasks.where((t) => t.isCompleted).toList();
    final totalFocusMinutes = completedTasks.fold<int>(
      0,
      (sum, t) => sum + t.durationMinutes,
    );
    final focusHours = totalFocusMinutes > 0 ? (totalFocusMinutes / 60.0) : 0.0;

    // Calculate Missions progress
    final totalMilestones = goals.fold<int>(
      0,
      (sum, g) => sum + g.milestones.length,
    );
    final completedMilestones = goals.fold<int>(
      0,
      (sum, g) => sum + g.milestones.where((m) => m.isCompleted).length,
    );
    final double missionsProgress = totalMilestones > 0
        ? (completedMilestones / totalMilestones)
        : (goals.isNotEmpty
              ? (goals.where((g) => g.isCompleted).length / goals.length)
              : 0.5);

    // Calculate Habits progress
    final double habitsProgress = tasks.isNotEmpty
        ? (completedTasks.length / tasks.length)
        : 0.5;

    // Focus hours progress (goal is 20 hours)
    final double focusHoursProgress = (focusHours / 20.0).clamp(0.0, 1.0);

    // Harmony Score
    final double harmonyScore =
        ((missionsProgress +
                    habitsProgress +
                    (focusHours > 0 ? focusHoursProgress : 0.5)) /
                3.0)
            .clamp(0.0, 1.0);

    // Automatic Milestone Unlocking
    bool milestonesUpdated = false;
    milestones = milestones.map((m) {
      bool shouldUnlock = m.isUnlocked;
      if (m.id == 'badge_clean_finish' &&
          tasks.isNotEmpty &&
          completedTasks.length == tasks.length) {
        shouldUnlock = true;
      } else if (m.id == 'badge_deep_work' && focusHours >= 10.0) {
        shouldUnlock = true;
      } else if (m.id == 'badge_evening_peace' && reflections.length >= 7) {
        shouldUnlock = true;
      } else if (m.id == 'badge_calm_mastery' &&
          goals.any((g) => g.isCompleted)) {
        shouldUnlock = true;
      } else if (m.id == 'badge_5day_flow' && reflections.length >= 5) {
        shouldUnlock = true;
      }
      if (shouldUnlock != m.isUnlocked) {
        milestonesUpdated = true;
        return m.copyWith(
          isUnlocked: true,
          unlockedDate: DateTime.now().toIso8601String().substring(0, 10),
        );
      }
      return m;
    }).toList();

    if (milestonesUpdated) {
      await _repo.saveMilestones(milestones);
    }

    state = state.copyWith(
      milestones: milestones,
      reflections: reflections,
      isLoading: false,
      missionsProgress: missionsProgress,
      habitsProgress: habitsProgress,
      focusHours: focusHours,
      focusHoursProgress: focusHoursProgress,
      harmonyScore: harmonyScore,
    );
  }

  Future<void> submitReflection({
    required String mood,
    required String note,
  }) async {
    final uuid = const Uuid();
    final now = DateTime.now();
    final reflection = DailyReflection(
      id: uuid.v4().substring(0, 8),
      date:
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      mood: mood,
      reflectionText: note,
      completedRitual: true,
      createdAt: now.toIso8601String(),
    );
    await _repo.saveReflection(reflection);
    await loadProgress();
  }
}

final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, ProgressState>(ProgressNotifier.new);

// --- User Profile & Theme State & Notifier ---
class UserProfileNotifier extends Notifier<UserProfile> {
  UserRepository get _repo => ref.read(userRepositoryProvider);

  @override
  UserProfile build() {
    Future.microtask(loadProfile);
    return UserProfile(
      id: 'user_default',
      name: 'Seeker',
      title: 'Intentional Builder',
      avatarUrl: '',
      hasCompletedOnboarding: false,
    );
  }

  Future<void> loadProfile() async {
    final profile = await _repo.getUserProfile();
    state = profile;
  }

  Future<void> completeOnboarding({
    required String name,
    required String title,
    required String eveningTime,
    required int focusDuration,
    required bool calmNotifications,
    String? avatarUrl,
    String? coachingTone,
  }) async {
    state = state.copyWith(
      name: name,
      title: title,
      avatarUrl: avatarUrl ?? state.avatarUrl,
      coachingTone: coachingTone ?? state.coachingTone,
      eveningRitualTime: eveningTime,
      focusTimerMinutes: focusDuration,
      calmNotificationsEnabled: calmNotifications,
      hasCompletedOnboarding: true,
    );
    await _repo.saveUserProfile(state);
  }

  Future<void> updateProfile({
    String? name,
    String? title,
    String? avatarUrl,
    String? coachingTone,
    String? eveningRitualTime,
    int? focusTimerMinutes,
  }) async {
    state = state.copyWith(
      name: name ?? state.name,
      title: title ?? state.title,
      avatarUrl: avatarUrl ?? state.avatarUrl,
      coachingTone: coachingTone ?? state.coachingTone,
      eveningRitualTime: eveningRitualTime ?? state.eveningRitualTime,
      focusTimerMinutes: focusTimerMinutes ?? state.focusTimerMinutes,
    );
    await _repo.saveUserProfile(state);
  }

  Future<void> toggleMissionLock() async {
    state = state.copyWith(missionLockEnabled: !state.missionLockEnabled);
    await _repo.saveUserProfile(state);
  }

  Future<void> toggleCalmNotifications() async {
    state = state.copyWith(
      calmNotificationsEnabled: !state.calmNotificationsEnabled,
    );
    await _repo.saveUserProfile(state);
  }

  Future<void> toggleAdaptivePacing() async {
    state = state.copyWith(adaptivePacingEnabled: !state.adaptivePacingEnabled);
    await _repo.saveUserProfile(state);
  }

  Future<void> setCoachingTone(String tone) async {
    state = state.copyWith(coachingTone: tone);
    await _repo.saveUserProfile(state);
  }

  Future<void> setFocusDuration(int minutes) async {
    state = state.copyWith(focusTimerMinutes: minutes);
    await _repo.saveUserProfile(state);
  }

  Future<void> setEveningRitualTime(String time) async {
    state = state.copyWith(eveningRitualTime: time);
    await _repo.saveUserProfile(state);
  }

  Future<void> setHapticsMode(String mode) async {
    state = state.copyWith(hapticsMode: mode);
    await _repo.saveUserProfile(state);
  }

  Future<void> resetAllDataAndReplayOnboarding() async {
    await _repo.clearAllData();
    state = UserProfile(
      id: 'user_default',
      name: 'Seeker',
      title: 'Intentional Builder',
      avatarUrl: '',
      hasCompletedOnboarding: false,
    );
    await ref.read(goalsNotifierProvider.notifier).loadGoals();
    await ref.read(tasksNotifierProvider.notifier).loadTasks();
    await ref.read(progressNotifierProvider.notifier).loadProgress();
  }
}

final userProfileNotifierProvider =
    NotifierProvider<UserProfileNotifier, UserProfile>(UserProfileNotifier.new);

// Aliases for backward compatibility and concise access
final goalsProvider = goalsNotifierProvider;
final todayTasksProvider = tasksNotifierProvider;
