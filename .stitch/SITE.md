# OneGoal App Architecture & UI Optimization Plan
**Stitch Project ID:** 16722238107092378204

## 1. App Vision
OneGoal is a mindful daily productivity mobile application built with Flutter & Riverpod. It embodies the philosophy of **"One Goal. One Day. One Next Step."** It replaces anxious backlogs and gamified stress with deep, calm focus.

---

## 2. Screen Map (5 Primary Tabs)

- [x] **Today Screen** (`today_screen.dart` / Stitch: `7c3c402c16df4c6cb524305cd83cbee4`)
  - Personalized greeting & formatted date
  - Today's Mission hero card with circular progress ring
  - Next actionable step ("In Focus") with Pomodoro timer trigger
  - Daily Flow time blocks with quick-complete and options sheet
  - Quick `+ Add Step` action button
- [x] **Timeline Screen** (`timeline_screen.dart` / Stitch: `8794ade49fb342a0b12fa17164c280d6`)
  - Interactive 7-day week ribbon with selected day indicator
  - Real-time live current time indicator line
  - Color-coded category time blocks with contextual options
  - Coach insight banner dynamically summarizing daily pacing
- [x] **Goals Screen** (`goals_screen.dart` / Stitch: `becae056500f45e7ab0db20170bcd9ed`)
  - Active 3-slot cap enforcement with clear user warning
  - Primary goal hero card with streak and milestones
  - Secondary goal expansion cards
  - Milestone breakdown sheet with 1-tap "Schedule in Today's Flow"
  - Enhanced NewGoalDialog with validation and milestone removal
- [x] **Progress Screen** (`progress_screen.dart` / Stitch: `142b6c9e12364b1cbfcdb12e893bad6c`)
  - Daily Harmony score with triple concentric rings (Mission, Flow, Reflection)
  - Weekly consistency rhythm bars
  - Quiet Milestones unlock system (12 peaceful markers of self-trust)
  - Interactive badge details dialog
- [x] **Profile Screen** (`profile_screen.dart` / Stitch: `501c28157c2f40f99b5b069290f24d8a`)
  - User identity avatar and tagline
  - Interactive Evening Reflection reminder time picker (`showTimePicker`)
  - Default focus duration picker dialog
  - Reset & replay onboarding wizard dialog
- [x] **Onboarding Screen** (`onboarding_screen.dart`)
  - 4-step mindful onboarding wizard (Philosophy, Identity, Preferences, First Mission)
- [x] **Evening Ritual Card** (`evening_ritual_card.dart`)
  - 2-minute reset ritual: mood selector, reflection notes, and peaceful completion

---

## 3. UI Optimization Loop Roadmap

1. **Today Screen Optimization**:
   - Audit Empty States: When no mission or no tasks exist, provide friendly, beautiful illustrations and 1-tap actions.
   - Enhance Pomodoro Timer interaction: Ensure smooth pause/resume/reset triggers and duration picker feedback.
2. **Timeline Screen Optimization**:
   - Time block category colors matching Stitch DESIGN tokens.
   - Empty state for unscheduled days.
3. **Goals Screen Optimization**:
   - Smooth expand/collapse animation for secondary goals.
   - Polished milestone progress percentage indicator.
4. **Progress Screen Optimization**:
   - Ensure the triple ring painter has smooth sweep angles and handles 0% gracefully.
5. **Continuous Verification**:
   - Run unit & widget tests on each iteration to guarantee 100% pass rate.
   - Run `flutter analyze` to ensure 0 warnings/errors.
