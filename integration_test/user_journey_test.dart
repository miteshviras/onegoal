import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('OneGoal Mindful User Journey E2E Test', () {
    late FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      await driver.close();
    });

    /*
     User Journey:
     1. Start on the Today home screen and verify the primary "Today's Mission" card.
     2. Navigate to "Goals" tab and verify the "Active Goals" horizon view is loaded.
     3. Navigate to "Timeline" tab and verify the daily rhythm view is loaded.
     4. Navigate to "Progress" tab and verify the weekly rhythm & harmony analytics view.
     5. Navigate to "Profile" tab and verify "Profile & Settings" and core mindfulness controls.
     6. Navigate back to "Today" tab and confirm the home view is properly restored.
    */
    test(
      'User navigates across all core tabs and verifies live state integrity',
      () async {
        // 1. Verify Today home screen
        final todayMissionFinder = find.text("Today's Mission");
        await driver.waitFor(todayMissionFinder);

        // 2. Navigate to Goals tab
        final goalsTabFinder = find.text('Goals');
        await driver.tap(goalsTabFinder);
        final activeGoalsFinder = find.text('Active Goals');
        await driver.waitFor(activeGoalsFinder);

        // 3. Navigate to Timeline tab
        final timelineTabFinder = find.text('Timeline');
        await driver.tap(timelineTabFinder);
        final focusModeFinder = find.text('Focus Mode');
        await driver.waitFor(focusModeFinder);

        // 4. Navigate to Progress tab
        final progressTabFinder = find.text('Progress');
        await driver.tap(progressTabFinder);
        final rhythmFinder = find.text('Intentional rhythm awaits');
        await driver.waitFor(rhythmFinder);

        // 5. Navigate to Profile tab
        final profileTabFinder = find.text('Profile');
        await driver.tap(profileTabFinder);
        final profileHeadingFinder = find.text('Profile & Settings');
        await driver.waitFor(profileHeadingFinder);

        // 6. Return back to Today tab
        final todayTabFinder = find.text('Today');
        await driver.tap(todayTabFinder);
        await driver.waitFor(todayMissionFinder);
      },
    );
  });
}
