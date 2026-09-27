import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegoal/main.dart';
import 'package:onegoal/presentation/providers/app_providers.dart';
import 'package:onegoal/presentation/screens/main_scaffold_screen.dart';
import 'package:onegoal/presentation/screens/progress_screen.dart';

void main() {
  testWidgets('OneGoalApp boots up fresh and renders OnboardingScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: OneGoalApp()));

    await tester.pumpAndSettle();

    // Fresh boot renders onboarding screen
    expect(find.text('Calm Focus.\nNot Endless Lists.'), findsOneWidget);
    expect(find.text('The Rule of One'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('MainScaffoldScreen renders main 5-tab focus layout', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MainScaffoldScreen())),
    );

    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });

  testWidgets('OnboardingScreen 5-step flow with 20% progress progression', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const ProviderScope(child: OneGoalApp()));
    await tester.pumpAndSettle();

    // Step 1 / 5: 20%
    expect(find.text('20%'), findsOneWidget);
    expect(find.text('STEP 1 OF 5'), findsOneWidget);
    expect(find.text('Calm Focus.\nNot Endless Lists.'), findsOneWidget);

    // Tap Continue -> Step 2 / 5: 40%
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('40%'), findsOneWidget);
    expect(find.text('STEP 2 OF 5'), findsOneWidget);
    expect(find.text('Personalize Your Profile'), findsOneWidget);
    expect(find.text('CHOOSE YOUR AVATAR'), findsOneWidget);

    // Tap Continue -> Step 3 / 5: 60% (New Rhythm Screen)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('60%'), findsOneWidget);
    expect(find.text('STEP 3 OF 5'), findsOneWidget);
    expect(find.text('Focus Rhythm & Coaching'), findsOneWidget);
    expect(find.text('COMPANION COACHING TONE'), findsOneWidget);
    expect(find.text('FOCUS SPRINT LENGTH'), findsOneWidget);
    expect(find.text('DAILY RHYTHMS'), findsOneWidget);

    // Tap Continue -> Step 4 / 5: 80% (Permissions)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('80%'), findsOneWidget);
    expect(find.text('STEP 4 OF 5'), findsOneWidget);
    expect(find.text('Quiet Permissions'), findsOneWidget);

    // Tap Continue -> Step 5 / 5: 100% (First Mission)
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('STEP 5 OF 5'), findsOneWidget);
    expect(find.text('Your First Mission'), findsOneWidget);
    expect(find.text('Enter Focus Sanctuary ✨'), findsOneWidget);
  });

  testWidgets(
    'ProgressScreen renders formatted focus hours without overflow on narrow screens',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            progressNotifierProvider.overrideWith(
              () => _TestProgressNotifier(),
            ),
          ],
          child: const MaterialApp(home: ProgressScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Formatted hours test: 0.4166666666666667 should be formatted to 0.4h
      expect(find.text('0.4h'), findsOneWidget);
      expect(find.text('0.4 recorded hours'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _TestProgressNotifier extends ProgressNotifier {
  @override
  ProgressState build() {
    return ProgressState(
      focusHours: 25.0 / 60.0, // 0.4166666666666667
      focusHoursProgress: 0.1,
      missionsProgress: 0.0,
      habitsProgress: 1.0,
      harmonyScore: 0.34,
    );
  }
}

