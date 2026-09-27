import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegoal/main.dart';
import 'package:onegoal/presentation/screens/main_scaffold_screen.dart';

void main() {
  testWidgets('OneGoalApp boots up fresh and renders OnboardingScreen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OneGoalApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Fresh boot renders onboarding screen
    expect(find.text('Calm Focus.\nNot Endless Lists.'), findsOneWidget);
    expect(find.text('The Rule of One'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('MainScaffoldScreen renders main 5-tab focus layout', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainScaffoldScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
  });
}
