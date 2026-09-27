# OneGoal — Comprehensive Setup & Developer Guide

Welcome to **OneGoal** (Mindful Daily Goal Planner), a behavior-first productivity application built with Flutter, Riverpod 3, and Google Stitch design tokens.

Core Philosophy: **“One Goal. One Day. One Next Step.”**

---

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Quickstart & Local Installation](#quickstart--local-installation)
3. [Running on Devices & Emulators](#running-on-devices--emulators)
4. [Project Architecture](#project-architecture)
5. [State Management (Riverpod 3)](#state-management-riverpod-3)
6. [Local Storage Architecture (Current Phase)](#local-storage-architecture-current-phase)
7. [Laravel Backend Integration Guide (Next Phase)](#laravel-backend-integration-guide-next-phase)
8. [Design Tokens & Theming](#design-tokens--theming)
9. [Code Quality & Testing](#code-quality--testing)

---

## 1. Prerequisites

Before setting up the project, ensure you have installed:
- **Flutter SDK**: `^3.47.0` (Tested on `Flutter 3.47.4`)
- **Dart SDK**: `^3.13.0` (Included with Flutter)
- **Git**
- IDE: **VS Code** (with Flutter & Dart extensions) or **Android Studio**
- Platform tooling depending on your target:
  - **Android**: Android Studio & Android SDK (API 34/35)
  - **iOS/macOS**: Xcode & CocoaPods (macOS only)
  - **Web**: Google Chrome / Microsoft Edge
  - **Windows**: Visual Studio with "Desktop development with C++"

Verify your environment by running:
```bash
flutter doctor
```

---

## 2. Quickstart & Local Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/miteshviras/onegoal.git
   cd onegoal
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify static analysis**:
   ```bash
   dart analyze
   ```
   *Expected output: `No issues found!`*

4. **Run unit & widget tests**:
   ```bash
   flutter test
   ```

---

## 3. Running on Devices & Emulators

Check available connected devices:
```bash
flutter devices
```

### Run on Web (Chrome):
```bash
flutter run -d chrome
```

### Run on Windows Desktop:
```bash
flutter run -d windows
```

### Run on Android Emulator or Physical Device:
```bash
flutter run -d <device-id>
```

---

## 4. Project Architecture

The application adheres to a clean layered architecture:

```
lib/
├── core/
│   ├── constants/
│   │   └── app_colors.dart         # Fidelity Dark & Paper Studio Light palettes
│   ├── services/
│   │   ├── storage_service.dart    # IStorageService & LocalStorageService
│   │   └── api_service.dart        # IApiService & LaravelApiClient
│   └── theme/
│       └── app_theme.dart          # Material 3 typography & themes
├── data/
│   ├── models/
│   │   ├── goal.dart               # Goal & GoalMilestone models with JSON mapping
│   │   ├── task_item.dart          # Actionable daily flow time-block model
│   │   ├── daily_reflection.dart   # Evening ritual check-in model
│   │   ├── quiet_milestone.dart    # Non-gamified milestone badges model
│   │   └── user_profile.dart       # User preferences, tones, & identity level
│   └── repositories/
│       ├── goal_repository.dart    # Persistent goal operations & seed data
│       ├── task_repository.dart    # Daily flow & timeline state persistence
│       ├── progress_repository.dart# Reflections & milestone badges persistence
│       └── user_repository.dart    # Profile settings & mindful preferences
├── presentation/
│   ├── providers/
│   │   └── app_providers.dart      # Modern Riverpod 3 Notifiers & Providers
│   ├── screens/
│   │   ├── main_scaffold_screen.dart # 5-tab persistent bottom navigation
│   │   ├── today_screen.dart       # Dominant hero mission, next step & flow
│   │   ├── goals_screen.dart       # 3-slot quarterly horizons & archive
│   │   ├── timeline_screen.dart    # Mini-week ribbon & vertical timeline
│   │   ├── progress_screen.dart    # Concentric triple rings & evening ritual
│   │   └── profile_screen.dart     # Settings, AI companion & data export
│   └── widgets/
│       ├── focus_glyph.dart        # Custom-painted focus branding icon
│       ├── progress_rings_painter.dart # Apple Health style triple rings
│       ├── evening_ritual_card.dart# Interactive 2-minute reset check-in
│       ├── goal_breakdown_sheet.dart # Milestone checklist bottom sheet
│       ├── new_goal_dialog.dart    # Goal creation dialog
│       └── new_task_dialog.dart    # Time block scheduling dialog
└── main.dart                       # App entrypoint with ProviderScope
```

---

## 5. State Management (Riverpod 3)

The project leverages modern **Riverpod 3** architecture using class-based `Notifier` and `NotifierProvider`:

- **`goalsNotifierProvider`**: Manages active goals, quarterly slot limits, today's mission selection, and milestone progress.
- **`tasksNotifierProvider`**: Manages daily flow time blocks, completion states, and in-focus tasks.
- **`focusTimerNotifierProvider`**: Manages real-time Pomodoro focus sessions (play, pause, countdown, and completion).
- **`progressNotifierProvider`**: Calculates harmony percentages and tracks evening reflections and quiet badges.
- **`userProfileNotifierProvider`**: Handles theme switching (`dark` vs `light`), mission locks, calm notifications, and AI coach tone.

---

## 6. Local Storage Architecture (Current Phase)

In the current standalone phase, all state is preserved locally via [`LocalStorageService`](lib/core/services/storage_service.dart) using `shared_preferences`.

- **Automatic Seeding**: On the first launch, realistic seed data (e.g., *"Ship Portfolio Website"*, *"Morning 5km Run Routine"*, and completed archival tasks) is initialized automatically.
- **Instant Persistence**: Any changes (marking a task complete, modifying goals, logging an evening check-in, changing theme) are immediately written to local storage.
- **Data Export & Reset**: Users can export their full dataset as Markdown/JSON or reset data from the **Profile** tab.

---

## 7. Laravel Backend Integration Guide (Next Phase)

The codebase has been designed from day one to connect seamlessly to a **Laravel REST API**.

### 7.1. Service Contract
Inspect [`lib/core/services/api_service.dart`](lib/core/services/api_service.dart). It defines:
- `IApiService`: The abstract interface for all backend calls.
- `LaravelApiClient`: The production-ready HTTP client implementation using `package:http`.

### 7.2. Expected Laravel Endpoints

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/v1/goals` | Retrieve all goals for authenticated user |
| `POST` | `/api/v1/goals` | Create a new goal |
| `PUT` | `/api/v1/goals/{id}` | Update goal or milestones |
| `DELETE` | `/api/v1/goals/{id}` | Delete goal |
| `GET` | `/api/v1/tasks` | Retrieve daily flow tasks for date |
| `POST` | `/api/v1/tasks` | Create scheduled time block |
| `PUT` | `/api/v1/tasks/{id}` | Toggle task completion |
| `POST` | `/api/v1/reflections`| Save daily evening check-in |
| `GET` | `/api/v1/user/profile` | Retrieve profile & preferences |
| `PUT` | `/api/v1/user/profile` | Update profile settings |

### 7.3. How to Connect Laravel
When your Laravel backend is deployed:

1. **Configure API Base URL & Auth**:
   In `lib/core/services/api_service.dart`, set your Laravel host:
   ```dart
   final apiService = LaravelApiClient(
     baseUrl: 'https://your-laravel-domain.com/api/v1',
     authToken: userSanctumToken,
   );
   ```

2. **Switch Repositories to API Service**:
   Update `goalRepositoryProvider` (or use an offline-first caching repository) in `lib/presentation/providers/app_providers.dart`:
   ```dart
   final goalRepositoryProvider = Provider<GoalRepository>((ref) {
     final apiService = ref.watch(apiServiceProvider);
     return RemoteGoalRepository(apiService);
   });
   ```
   *Because models already have matching `toMap()`, `fromMap()`, `toJson()`, and `fromJson()`, no model changes are required!*

---

## 8. Design Tokens & Theming

Designed in accordance with the **Google Stitch** behavioral productivity system:
- **Dark Graphite (Fidelity Theme)**:
  - Background/Surface: `#111319`
  - Container Low/High: `#191C22` / `#272A30`
  - Focus Primary: `#ACC7FF` & `#0E5FC3`
  - Emerald Success: `#10B981`
  - Soft Coral/Amber: `#FFB68A`
- **Paper Studio (Warm Light Theme)**:
  - Background/Surface: `#FAF9F6`
  - Container: `#F0EDF1`
  - Deep Navy Primary: `#1E3A8A`
- **Custom Visual Components**:
  - `FocusGlyph`: Circular vector focus mark.
  - `TripleProgressRings`: Dynamic triple concentric SVG-style rings rendered via `CustomPainter`.

---

## 9. Code Quality & Testing

Run all code quality checks before committing:

```bash
# Run Dart static analyzer
dart analyze

# Run Flutter automated tests
flutter test

# Format all Dart files
dart format .
```
