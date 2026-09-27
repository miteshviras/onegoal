import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'timeline_screen.dart';
import 'today_screen.dart';

class MainScaffoldScreen extends StatefulWidget {
  const MainScaffoldScreen({super.key});

  @override
  State<MainScaffoldScreen> createState() => _MainScaffoldScreenState();
}

class _MainScaffoldScreenState extends State<MainScaffoldScreen> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(onOpenProfile: () => _onTabSelected(4)),
      const GoalsScreen(),
      const TimelineScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withValues(alpha: 0.95),
          border: Border(
            top: BorderSide(
              color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(index: 0, icon: Icons.light_mode, label: 'Today'),
                _buildNavItem(
                  index: 1,
                  icon: Icons.track_changes,
                  label: 'Goals',
                ),
                _buildNavItem(
                  index: 2,
                  icon: Icons.schedule,
                  label: 'Timeline',
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.donut_large,
                  label: 'Progress',
                ),
                _buildNavItem(index: 4, icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTabSelected(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 48),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.darkOnSurfaceVariant,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? AppColors.primary
                    : AppColors.darkOnSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
