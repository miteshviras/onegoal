import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:onegoal/main.dart';

void main() {
  testWidgets('OneGoalApp boots up and renders main screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: OneGoalApp(),
      ),
    );

    // Initial pump and settle
    await tester.pumpAndSettle();

    // Verify key titles from the design
    expect(find.text('Focus'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text("Today's Mission"), findsOneWidget);
  });
}
