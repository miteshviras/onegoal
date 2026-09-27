import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegoal/core/services/storage_service.dart';
import 'package:onegoal/presentation/providers/app_providers.dart';
import 'package:onegoal/presentation/screens/today_screen.dart';
import 'package:onegoal/presentation/screens/timeline_screen.dart';
import 'package:onegoal/presentation/screens/goals_screen.dart';
import 'package:onegoal/presentation/screens/progress_screen.dart';
import 'package:onegoal/presentation/screens/profile_screen.dart';
import 'package:onegoal/presentation/widgets/new_goal_dialog.dart';
import 'package:onegoal/presentation/widgets/evening_ritual_card.dart';

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

Widget createTestWidget(Widget child, [ProviderContainer? container]) {
  return UncontrolledProviderScope(
    container: container ??
        ProviderContainer(
          overrides: [
            storageServiceProvider.overrideWithValue(InMemoryStorageService()),
          ],
        ),
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TodayScreen Widget Tests', () {
    testWidgets('Renders header greeting, mission card, focus timer, and daily flow',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      // Preload a task and a mission
      await container.read(goalsNotifierProvider.notifier).createGoal(
            title: 'Ship OneGoal V2',
            description: 'Flawless design and architecture',
            category: 'Engineering',
            dueInDays: 7,
            affirmation: 'Execute with calm focus',
          );
      final goal = container.read(goalsNotifierProvider).goals.first;
      await container.read(goalsNotifierProvider.notifier).setTodayMission(goal.id);

      await container.read(tasksNotifierProvider.notifier).addTask(
            title: 'Audit stitch designs',
            subtitle: 'Timeline and Today alignments',
            scheduledTime: '10:00 AM',
            durationMinutes: 25,
          );

      await tester.pumpWidget(createTestWidget(TodayScreen(onOpenProfile: () {}), container));
      await tester.pumpAndSettle();

      // Greeting and date check
      expect(find.textContaining('Good'), findsOneWidget);
      expect(find.text("Today's Mission"), findsOneWidget);
      expect(find.text('Ship OneGoal V2'), findsOneWidget);
      expect(find.text('In Focus'), findsOneWidget);
      expect(find.text('Daily Flow'), findsOneWidget);
      expect(find.text('Add Step'), findsOneWidget);
      // Appears in both In Focus hero card and Daily Flow list
      expect(find.text('Audit stitch designs'), findsNWidgets(2));
    });

    testWidgets('Tapping Add Step opens NewTaskDialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(InMemoryStorageService()),
        ],
      );

      await tester.pumpWidget(createTestWidget(TodayScreen(onOpenProfile: () {}), container));
      await tester.pumpAndSettle();

      final addStepBtn = find.text('Add Step');
      expect(addStepBtn, findsOneWidget);
      await tester.tap(addStepBtn);
      await tester.pumpAndSettle();

      expect(find.text('+ Add Time Block'), findsOneWidget);
      expect(find.text('Action Title'), findsOneWidget);
    });

    testWidgets('Empty mission card shows Choose Today\'s Mission and allows selection',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(InMemoryStorageService()),
        ],
      );

      // Create an unselected goal
      await container.read(goalsNotifierProvider.notifier).createGoal(
            title: 'Master Flutter UI',
            description: 'Stitch design alignments',
            category: 'Career & Craft',
            dueInDays: 14,
            affirmation: 'Consistency is power',
          );

      await tester.pumpWidget(createTestWidget(TodayScreen(onOpenProfile: () {}), container));
      await tester.pumpAndSettle();

      // No mission card should show
      expect(find.text('No Mission Active Today'), findsOneWidget);
      expect(find.text("Choose Today's Mission"), findsOneWidget);

      // Open selector sheet
      await tester.tap(find.text("Choose Today's Mission"));
      await tester.pumpAndSettle();

      expect(find.text('Select the single active goal to anchor your focus today.'),
          findsOneWidget);
      expect(find.text('Master Flutter UI'), findsOneWidget);

      // Tap goal to set as mission
      await tester.tap(find.text('Master Flutter UI'));
      await tester.pumpAndSettle();

      // Mission hero card is now active!
      expect(find.text("Today's Mission"), findsOneWidget);
      expect(find.text('Master Flutter UI'), findsOneWidget);
    });
  });

  group('TimelineScreen Widget Tests', () {
    testWidgets('Renders week ribbon, time blocks, and live indicator',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await container.read(tasksNotifierProvider.notifier).addTask(
            title: 'Morning Deep Work',
            subtitle: 'Architecture review',
            scheduledTime: '9:00 AM',
            durationMinutes: 45,
          );

      await tester.pumpWidget(createTestWidget(const TimelineScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('MINDFUL CADENCE'), findsOneWidget);
      expect(find.text('Morning Deep Work'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('Empty timeline shows guidance and Add Focus Block button', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(createTestWidget(const TimelineScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('No Scheduled Blocks Today'), findsOneWidget);
      expect(find.text('Add Focus Block'), findsOneWidget);

      await tester.tap(find.text('Add Focus Block'));
      await tester.pumpAndSettle();

      expect(find.text('+ Add Time Block'), findsOneWidget);
    });
  });

  group('GoalsScreen Widget Tests', () {
    testWidgets('Renders active slots pill and goal cards', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await container.read(goalsNotifierProvider.notifier).createGoal(
            title: 'Daily Meditation',
            description: '15 mins mindfulness',
            category: 'Health',
            dueInDays: 30,
            affirmation: 'Peace begins with breath',
          );

      await tester.pumpWidget(createTestWidget(const GoalsScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Active Goals'), findsOneWidget);
      expect(find.text('1 of 3 slots'), findsOneWidget);
      expect(find.text('Daily Meditation'), findsOneWidget);
      expect(find.text('+ New Horizon'), findsOneWidget);
    });

    testWidgets('Promotes today\'s mission to primary hero card', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      // Create Goal A (not mission)
      await container.read(goalsNotifierProvider.notifier).createGoal(
            title: 'Goal A - Regular',
            description: 'Regular priority',
            category: 'Personal Growth',
            dueInDays: 30,
            affirmation: 'Slow and steady',
          );

      // Create Goal B (will be set as today's mission)
      await container.read(goalsNotifierProvider.notifier).createGoal(
            title: 'Goal B - Focus Mission',
            description: 'Top priority today',
            category: 'Career & Craft',
            dueInDays: 14,
            affirmation: 'Laser focus',
          );

      final goals = container.read(goalsNotifierProvider).goals;
      final goalB = goals.firstWhere((g) => g.title == 'Goal B - Focus Mission');
      await container.read(goalsNotifierProvider.notifier).setTodayMission(goalB.id);

      await tester.pumpWidget(createTestWidget(const GoalsScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('2 of 3 slots'), findsOneWidget);
      expect(find.text("Today's Mission"), findsOneWidget);
      expect(find.text('Goal B - Focus Mission'), findsOneWidget);
      expect(find.text('Secondary Active Horizons (1)'), findsOneWidget);
      expect(find.text('Goal A - Regular'), findsOneWidget);
    });
  });

  group('ProgressScreen Widget Tests', () {
    testWidgets('Renders weekly rhythm, triple rings, and badges dialog',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(createTestWidget(const ProgressScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('WEEKLY RHYTHM'), findsOneWidget);
      expect(find.text('All 12 Badges'), findsWidgets);

      // Open Badges Dialog from the AppBar action button
      await tester.tap(find.text('All 12 Badges').first);
      await tester.pumpAndSettle();

      expect(find.text('Quiet Milestones (12)'), findsOneWidget);
      expect(find.text('Gentle markers of self-trust, never gamified or anxious.'),
          findsOneWidget);
    });
  });

  group('ProfileScreen Widget Tests', () {
    testWidgets('Renders settings sections and timer options', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(createTestWidget(const ProfileScreen(), container));
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.textContaining('WELL-BEING'), findsOneWidget);
      expect(find.text('Daily Mission Lock'), findsOneWidget);
      expect(find.text('Calm Notifications'), findsOneWidget);
      expect(find.text('Focus Timer Duration'), findsOneWidget);

      // Tap Focus Timer Duration to open dialog
      await tester.tap(find.text('Focus Timer Duration'));
      await tester.pumpAndSettle();

      expect(find.text('25 minutes'), findsOneWidget);
      expect(find.text('45 minutes'), findsOneWidget);
    });
  });

  group('NewGoalDialog Widget Tests', () {
    testWidgets('Validates empty title and allows dynamic milestone modification',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(createTestWidget(const NewGoalDialog(), container));
      await tester.pumpAndSettle();

      expect(find.text('+ New Horizon'), findsOneWidget);
      expect(find.text('Goal Title'), findsOneWidget);
      expect(find.text('Create Goal'), findsOneWidget);

      // Attempt to save with empty title
      await tester.tap(find.text('Create Goal'));
      await tester.pumpAndSettle();

      // Error message should be shown
      expect(find.text('Please enter a goal title'), findsOneWidget);

      // Add a milestone field
      expect(find.text('Add'), findsOneWidget);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Milestone 4'), findsOneWidget);

      // Enter valid title
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g. Master Design Systems in Flutter'),
          'Master Flutter 3.x');
      await tester.pumpAndSettle();

      expect(find.text('Please enter a goal title'), findsNothing);

      // Create goal successfully
      await tester.tap(find.text('Create Goal'));
      await tester.pumpAndSettle();

      expect(find.text('+ New Horizon'), findsNothing);
    });
  });

  group('EveningRitualCard Widget Tests', () {
    testWidgets('Renders mood options, note input, and saves ritual', (tester) async {
      final storage = InMemoryStorageService();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await tester.pumpWidget(
        createTestWidget(
          const Scaffold(body: SingleChildScrollView(child: EveningRitualCard())),
          container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Evening Check-in'), findsOneWidget);
      expect(find.text('Great'), findsOneWidget);
      expect(find.text('Balanced'), findsOneWidget);
      expect(find.text('Tough'), findsOneWidget);
      expect(find.text('Complete Ritual'), findsOneWidget);

      // Tap Balanced mood
      await tester.tap(find.text('Balanced'));
      await tester.pumpAndSettle();

      // Enter reflection note
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'Shipped core features peacefully today.');
      await tester.pumpAndSettle();

      // Submit ritual
      await tester.tap(find.text('Complete Ritual'));
      await tester.pumpAndSettle();

      expect(find.text('Ritual Done'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}
