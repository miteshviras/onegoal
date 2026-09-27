import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegoal/core/services/storage_service.dart';
import 'package:onegoal/presentation/providers/app_providers.dart';

class InMemoryStorageService implements IStorageService {
  final Map<String, String> _data = {};

  @override
  Future<void> saveString(String key, String value) async => _data[key] = value;

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> remove(String key) async => _data.remove(key);

  @override
  Future<void> clear() async => _data.clear();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late InMemoryStorageService storage;

  setUp(() {
    storage = InMemoryStorageService();
    container = ProviderContainer(
      overrides: [storageServiceProvider.overrideWithValue(storage)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GoalsNotifier Tests', () {
    test('Create goal, toggle milestone, complete and delete goal', () async {
      final notifier = container.read(goalsNotifierProvider.notifier);

      await notifier.createGoal(
        title: 'Master Flutter Animations',
        description: 'Implement fluid micro-interactions',
        category: 'Craft',
        dueInDays: 21,
        affirmation: 'Motion brings meaning',
        milestoneTitles: ['Learn Implicit Animations', 'Master CustomPainter'],
      );

      final state = container.read(goalsNotifierProvider);
      expect(state.goals.length, equals(1));
      final goal = state.goals.first;
      expect(goal.title, equals('Master Flutter Animations'));
      expect(goal.milestones.length, equals(2));
      expect(goal.progress, equals(0.0));

      // Toggle first milestone
      final firstMilestoneId = goal.milestones.first.id;
      await notifier.toggleMilestone(goal.id, firstMilestoneId);

      final stateAfterMilestone = container.read(goalsNotifierProvider);
      final updatedGoal = stateAfterMilestone.goals.first;
      expect(updatedGoal.milestones.first.isCompleted, isTrue);
      expect(updatedGoal.progress, equals(0.5));

      // Set as today's mission
      await notifier.setTodayMission(goal.id);
      expect(
        container.read(goalsNotifierProvider).todayMission?.id,
        equals(goal.id),
      );

      // Complete goal
      await notifier.completeGoal(goal.id);
      final stateAfterComplete = container.read(goalsNotifierProvider);
      expect(stateAfterComplete.completedGoals.length, equals(1));
      expect(stateAfterComplete.activeGoals.isEmpty, isTrue);

      // Delete goal
      await notifier.deleteGoal(goal.id);
      expect(container.read(goalsNotifierProvider).goals.isEmpty, isTrue);
    });
  });

  group('TasksNotifier Tests', () {
    test('Add task, set focus, toggle completion, and delete', () async {
      final notifier = container.read(tasksNotifierProvider.notifier);

      await notifier.addTask(
        title: 'Write adaptive icon unit test',
        subtitle: 'Cover foreground and background',
        scheduledTime: '11:00 AM',
        durationMinutes: 30,
      );

      await notifier.addTask(
        title: 'Document architecture decision',
        subtitle: 'Update design doc',
        scheduledTime: '2:00 PM',
        durationMinutes: 20,
      );

      var state = container.read(tasksNotifierProvider);
      expect(state.tasks.length, equals(2));
      expect(state.totalCount, equals(2));
      expect(state.completedCount, equals(0));

      // First task defaults to focus or can be explicitly focused
      final firstTaskId = state.tasks.first.id;
      final secondTaskId = state.tasks[1].id;

      await notifier.setFocusTask(secondTaskId);
      state = container.read(tasksNotifierProvider);
      expect(state.inFocusTask?.id, equals(secondTaskId));

      // Toggle completion of first task
      await notifier.toggleTask(firstTaskId);
      state = container.read(tasksNotifierProvider);
      expect(state.completedCount, equals(1));
      expect(
        state.tasks.firstWhere((t) => t.id == firstTaskId).isCompleted,
        isTrue,
      );

      // Delete second task
      await notifier.deleteTask(secondTaskId);
      state = container.read(tasksNotifierProvider);
      expect(state.tasks.length, equals(1));
      expect(state.totalCount, equals(1));
    });
  });

  group('FocusTimerNotifier Tests', () {
    test('Timer start, pause, reset, and setDuration', () {
      final notifier = container.read(focusTimerNotifierProvider.notifier);

      notifier.setDuration(15);
      var state = container.read(focusTimerNotifierProvider);
      expect(state.totalSeconds, equals(15 * 60));
      expect(state.remainingSeconds, equals(15 * 60));
      expect(state.status, equals(TimerStatus.initial));

      notifier.startOrResume();
      state = container.read(focusTimerNotifierProvider);
      expect(state.status, equals(TimerStatus.running));

      notifier.pause();
      state = container.read(focusTimerNotifierProvider);
      expect(state.status, equals(TimerStatus.paused));

      notifier.reset();
      state = container.read(focusTimerNotifierProvider);
      expect(state.status, equals(TimerStatus.initial));
      expect(state.remainingSeconds, equals(15 * 60));
    });
  });

  group('UserProfileNotifier Tests', () {
    test('Settings toggles and preferences', () async {
      final notifier = container.read(userProfileNotifierProvider.notifier);
      await Future.delayed(Duration.zero);
      await notifier.loadProfile();

      final initialLock = container
          .read(userProfileNotifierProvider)
          .missionLockEnabled;
      await notifier.toggleMissionLock();
      expect(
        container.read(userProfileNotifierProvider).missionLockEnabled,
        equals(!initialLock),
      );

      await notifier.toggleCalmNotifications();
      expect(
        container.read(userProfileNotifierProvider).calmNotificationsEnabled,
        isFalse,
      );

      await notifier.setFocusDuration(45);
      expect(
        container.read(userProfileNotifierProvider).focusTimerMinutes,
        equals(45),
      );

      await notifier.setEveningRitualTime('9:30 PM');
      expect(
        container.read(userProfileNotifierProvider).eveningRitualTime,
        equals('9:30 PM'),
      );

      await notifier.setCoachingTone('concise');
      expect(
        container.read(userProfileNotifierProvider).coachingTone,
        equals('concise'),
      );
    });

    test('updateProfile updates all fields and persists profile', () async {
      final notifier = container.read(userProfileNotifierProvider.notifier);
      await Future.delayed(Duration.zero);
      await notifier.loadProfile();

      await notifier.updateProfile(
        name: 'Alex Sterling',
        title: 'Lead Architect',
        avatarUrl: 'assets/images/app_logo.png',
        coachingTone: 'concise',
        eveningRitualTime: '10:00 PM',
        focusTimerMinutes: 50,
      );

      final state = container.read(userProfileNotifierProvider);
      expect(state.name, equals('Alex Sterling'));
      expect(state.title, equals('Lead Architect'));
      expect(state.avatarUrl, equals('assets/images/app_logo.png'));
      expect(state.coachingTone, equals('concise'));
      expect(state.eveningRitualTime, equals('10:00 PM'));
      expect(state.focusTimerMinutes, equals(50));
    });
  });

  group('ProgressNotifier Tests', () {
    test('Dynamic harmony calculation and auto milestone unlocking', () async {
      // Add tasks and complete them to trigger real progress
      final tasksNotifier = container.read(tasksNotifierProvider.notifier);
      await tasksNotifier.addTask(
        title: 'Task A',
        subtitle: 'Sub A',
        scheduledTime: '9:00 AM',
        durationMinutes: 25,
      );
      final taskId = container.read(tasksNotifierProvider).tasks.first.id;
      await tasksNotifier.toggleTask(taskId);

      final progressNotifier = container.read(
        progressNotifierProvider.notifier,
      );
      await progressNotifier.loadProgress();

      final state = container.read(progressNotifierProvider);
      expect(state.missionsProgress, greaterThan(0.0));
      expect(state.harmonyScore, greaterThan(0.0));

      // Clean finish badge unlocks when all tasks are complete
      final cleanFinishBadge = state.milestones.firstWhere(
        (m) => m.id == 'badge_clean_finish',
        orElse: () => state.milestones.first,
      );
      expect(cleanFinishBadge.isUnlocked, isTrue);
    });
  });
}
