import 'package:flutter_test/flutter_test.dart';
import 'package:onegoal/data/models/goal.dart';
import 'package:onegoal/data/models/task_item.dart';
import 'package:onegoal/data/models/user_profile.dart';
import 'package:onegoal/data/models/quiet_milestone.dart';
import 'package:onegoal/data/models/daily_reflection.dart';

void main() {
  group('Goal Model Tests', () {
    test('Goal and GoalMilestone serialization/deserialization', () {
      final milestone = GoalMilestone(
        id: 'm1',
        title: 'Draft wireframes',
        isCompleted: true,
        completedAt: '2026-10-01',
      );

      final goal = Goal(
        id: 'g1',
        title: 'Master Flutter UI',
        description: 'Build calm and high fidelity apps',
        category: 'Craft',
        dueInDays: 14,
        progress: 0.5,
        isTodayMission: true,
        streakDays: 4,
        affirmation: 'Progress over perfection',
        imageUrl: 'https://example.com/art.jpg',
        milestones: [milestone],
        isCompleted: false,
      );

      final jsonString = goal.toJson();
      final decodedGoal = Goal.fromJson(jsonString);

      expect(decodedGoal.id, equals('g1'));
      expect(decodedGoal.title, equals('Master Flutter UI'));
      expect(decodedGoal.milestones.length, equals(1));
      expect(decodedGoal.milestones.first.title, equals('Draft wireframes'));
      expect(decodedGoal.milestones.first.isCompleted, isTrue);
      expect(decodedGoal.isTodayMission, isTrue);
    });

    test('Goal copyWith updates attributes without mutating original', () {
      final goal = Goal(
        id: 'g2',
        title: 'Launch Project',
        description: 'Ship version 1.0',
        category: 'Work',
      );

      final updated = goal.copyWith(
        isCompleted: true,
        progress: 1.0,
        completedAt: 'Today',
      );

      expect(goal.isCompleted, isFalse);
      expect(updated.isCompleted, isTrue);
      expect(updated.progress, equals(1.0));
      expect(updated.completedAt, equals('Today'));
      expect(updated.title, equals(goal.title));
    });
  });

  group('TaskItem Model Tests', () {
    test('TaskItem serialization/deserialization', () {
      final task = TaskItem(
        id: 't1',
        goalId: 'g1',
        title: 'Design adaptive icon',
        subtitle: 'Foreground and background layers',
        scheduledTime: '10:00 AM',
        durationMinutes: 45,
        isCompleted: false,
        isCurrentFocus: true,
        stepNumber: 2,
        totalSteps: 4,
      );

      final jsonStr = task.toJson();
      final decoded = TaskItem.fromJson(jsonStr);

      expect(decoded.id, equals('t1'));
      expect(decoded.goalId, equals('g1'));
      expect(decoded.title, equals('Design adaptive icon'));
      expect(decoded.durationMinutes, equals(45));
      expect(decoded.isCurrentFocus, isTrue);
      expect(decoded.stepNumber, equals(2));
    });

    test('TaskItem copyWith maintains consistency', () {
      final task = TaskItem(
        id: 't2',
        title: 'Review PR',
        scheduledTime: '2:00 PM',
      );

      final completedTask = task.copyWith(
        isCompleted: true,
        completedAt: '2:45 PM',
      );

      expect(task.isCompleted, isFalse);
      expect(completedTask.isCompleted, isTrue);
      expect(completedTask.completedAt, equals('2:45 PM'));
    });
  });

  group('UserProfile Model Tests', () {
    test('UserProfile evolution properties', () {
      final profile = UserProfile(
        id: 'u1',
        name: 'Mitesh',
        title: 'Product Architect',
        avatarUrl: 'assets/images/avatar.png',
        level: 3,
        score: 350,
        pointsToNextLevel: 50,
        evolutionProgress: 0.5,
        streakDays: 12,
      );

      expect(profile.id, equals('u1'));
      expect(profile.level, equals(3));
      expect(profile.pointsToNextLevel, equals(50));
      expect(profile.evolutionProgress, equals(0.5));
    });

    test('UserProfile settings serialization/deserialization', () {
      final profile = UserProfile(
        id: 'u2',
        name: 'Alex',
        title: 'Mindful Developer',
        avatarUrl: '',
        missionLockEnabled: false,
        calmNotificationsEnabled: true,
        eveningRitualTime: '9:15 PM',
        focusTimerMinutes: 45,
        coachingTone: 'concise',
      );

      final jsonStr = profile.toJson();
      final decoded = UserProfile.fromJson(jsonStr);

      expect(decoded.name, equals('Alex'));
      expect(decoded.missionLockEnabled, isFalse);
      expect(decoded.calmNotificationsEnabled, isTrue);
      expect(decoded.eveningRitualTime, equals('9:15 PM'));
      expect(decoded.focusTimerMinutes, equals(45));
      expect(decoded.coachingTone, equals('concise'));
    });
  });

  group('QuietMilestone and DailyReflection Tests', () {
    test('QuietMilestone copyWith and json conversion', () {
      final milestone = QuietMilestone(
        id: 'qm1',
        title: 'Clean Finish',
        subtitle: 'Completed all steps',
        iconKey: 'done_all',
        isUnlocked: false,
      );

      final unlocked = milestone.copyWith(
        isUnlocked: true,
        unlockedDate: '2026-10-02',
      );

      expect(unlocked.isUnlocked, isTrue);
      expect(unlocked.unlockedDate, equals('2026-10-02'));

      final jsonStr = unlocked.toJson();
      final decoded = QuietMilestone.fromJson(jsonStr);
      expect(decoded.title, equals('Clean Finish'));
      expect(decoded.isUnlocked, isTrue);
      expect(decoded.unlockedDate, equals('2026-10-02'));
    });

    test('DailyReflection serialization', () {
      final reflection = DailyReflection(
        id: 'r1',
        date: '2026-10-24',
        mood: 'great',
        reflectionText: 'Felt deep flow and calm progress.',
        completedRitual: true,
        createdAt: '2026-10-24T21:00:00Z',
      );

      final jsonStr = reflection.toJson();
      final decoded = DailyReflection.fromJson(jsonStr);

      expect(decoded.id, equals('r1'));
      expect(decoded.mood, equals('great'));
      expect(decoded.reflectionText, contains('deep flow'));
      expect(decoded.completedRitual, isTrue);
    });
  });
}
