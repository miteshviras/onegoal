import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/screens/main_scaffold_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(
    const ProviderScope(
      child: OneGoalApp(),
    ),
  );
}

class OneGoalApp extends ConsumerWidget {
  const OneGoalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileNotifierProvider);

    ThemeMode themeMode;
    switch (userProfile.themeMode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'system':
        themeMode = ThemeMode.system;
        break;
      case 'dark':
      default:
        themeMode = ThemeMode.dark;
        break;
    }

    return MaterialApp(
      title: 'OneGoal - Mindful Daily Planner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainScaffoldScreen(),
    );
  }
}
