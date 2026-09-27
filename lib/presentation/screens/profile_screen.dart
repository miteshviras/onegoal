import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showTimerDurationDialog(BuildContext context, WidgetRef ref, int current) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: AppColors.darkSurfaceContainer,
          title: const Text(
            'Focus Timer Duration',
            style: TextStyle(
              color: AppColors.darkOnSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          children: [15, 20, 25, 30, 45, 50].map((mins) {
            return SimpleDialogOption(
              onPressed: () {
                ref
                    .read(userProfileNotifierProvider.notifier)
                    .setFocusDuration(mins);
                ref
                    .read(focusTimerNotifierProvider.notifier)
                    .setTaskAndDuration(
                      ref.read(tasksNotifierProvider).inFocusTask?.title ??
                          'Deep Focus Sprint',
                      mins,
                    );
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$mins minutes',
                      style: TextStyle(
                        fontSize: 15,
                        color: mins == current
                            ? AppColors.primary
                            : AppColors.darkOnSurface,
                        fontWeight: mins == current
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (mins == current)
                      const Icon(Icons.check, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }



  void _showMindfulBreakDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkSurfaceContainer,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Take a Mindful Break',
            style: TextStyle(
              color: AppColors.darkOnSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Step away from screens, breathe deeply, and reconnect with the present moment. Your progress is saved quietly.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkOnSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Resume Later'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Breathe in calm. Exhale tension.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
              ),
              child: const Text('Begin Break'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileNotifierProvider);
    final notifier = ref.read(userProfileNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withValues(alpha: 0.9),
            border: Border(
              bottom: BorderSide(
                color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'Profile & Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Icon(
                    Icons.tune,
                    color: AppColors.darkOutline,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          children: [
            // User Avatar & Bio
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainer,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: ClipOval(
                          child: profile.avatarUrl.startsWith('assets/')
                              ? Image.asset(profile.avatarUrl, fit: BoxFit.cover)
                              : Image.network(
                                  profile.avatarUrl.isNotEmpty
                                      ? profile.avatarUrl
                                      : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=200&q=80',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.person,
                                    color: AppColors.primary,
                                    size: 44,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceContainerLow,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: const BoxDecoration(
                                color: AppColors.successEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    profile.title,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkOnSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Consistent Practitioner • ${profile.streakDays} Days Active',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Gentle Philosophy Quote Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'CORE PRINCIPLE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkOutline,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '“One Goal. One Day. One Next Step.”',
                          style: TextStyle(
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Focus & Well-being Settings
            _buildSectionHeader(
              title: 'Focus & Well-being',
              badge: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Mindful Rhythm',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.successEmerald,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.lock_clock,
                    title: 'Daily Mission Lock',
                    subtitle: 'Limit focus to 1 high-impact priority per day',
                    value: profile.missionLockEnabled,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.toggleMissionLock();
                    },
                  ),
                  _buildDivider(),
                  _buildSwitchTile(
                    icon: Icons.notifications_paused,
                    title: 'Calm Notifications',
                    subtitle: 'Zero guilt triggers; gentle next-step nudges only',
                    value: profile.calmNotificationsEnabled,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.toggleCalmNotifications();
                    },
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.nightlight,
                    title: 'Evening Reflection Ritual',
                    subtitle: 'Gentle wind-down & uncompleted task rollover',
                    trailing: Text(
                      profile.eveningRitualTime,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: const TimeOfDay(hour: 21, minute: 0),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.dark(
                                primary: AppColors.primary,
                                surface: AppColors.darkSurfaceContainer,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null && context.mounted) {
                        final formatted = picked.format(context);
                        notifier.setEveningRitualTime(formatted);
                      }
                    },
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.timer,
                    title: 'Focus Timer Duration',
                    subtitle: 'Default cadence per active burst',
                    trailing: Text(
                      '${profile.focusTimerMinutes} min',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    onTap: () => _showTimerDurationDialog(
                        context, ref, profile.focusTimerMinutes),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Companion Behavior
            _buildSectionHeader(
              title: 'AI Companion Behavior',
              badge: Row(
                children: const [
                  Icon(Icons.auto_awesome,
                      color: AppColors.tertiary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Adaptive',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSwitchTile(
                    icon: Icons.smart_toy,
                    title: 'Proactive Schedule Adjustments',
                    subtitle: 'Suggests pacing changes when your energy dips',
                    value: profile.adaptivePacingEnabled,
                    onChanged: (val) {
                      HapticFeedback.selectionClick();
                      notifier.toggleAdaptivePacing();
                    },
                  ),
                  _buildDivider(),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceContainerHigh,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.sentiment_satisfied,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Coaching Tone',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkOnSurface,
                                ),
                              ),
                              Text(
                                'How prompts speak to you',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.darkOutline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTonePill(
                          title: 'Supportive & Gentle',
                          icon: Icons.favorite,
                          isSelected: profile.coachingTone == 'gentle',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setCoachingTone('gentle');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildTonePill(
                          title: 'Direct & Concise',
                          icon: Icons.qr_code_2,
                          isSelected: profile.coachingTone == 'concise',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            notifier.setCoachingTone('concise');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Application & Data
            _buildSectionHeader(title: 'Application & Data'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildNavigationTile(
                    icon: Icons.vibration,
                    title: 'Haptics & Motion',
                    subtitle: 'Gentle click feedback on completion',
                    trailing: const Text(
                      'Soft',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.successEmerald,
                      ),
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                    },
                  ),
                  _buildDivider(),
                  _buildNavigationTile(
                    icon: Icons.refresh_rounded,
                    title: 'Reset All Data & Replay Onboarding',
                    subtitle: 'Clear all storage and test from fresh',
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.errorMuted,
                      size: 20,
                    ),
                    onTap: () => _showResetDataDialog(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Mindful Break / Log Out
            OutlinedButton.icon(
              onPressed: () => _showMindfulBreakDialog(context, ref),
              icon: const Icon(Icons.logout, color: AppColors.errorMuted, size: 18),
              label: const Text(
                'Take a Mindful Break (Log Out)',
                style: TextStyle(
                  color: AppColors.darkOnSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColors.darkSurfaceContainerLow,
                side: BorderSide(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Focus Planner v2.4.1 • Calm Architecture',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.darkOutline,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required String title, Widget? badge}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.darkOutline,
            letterSpacing: 0.6,
          ),
        ),
        ?badge,
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkOnSurfaceVariant, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.darkOutline,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primaryContainer,
            inactiveTrackColor: AppColors.darkSurfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.darkOnSurfaceVariant, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.darkOutline,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildTonePill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.darkSurfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.darkOutlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : AppColors.darkOutline,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.darkOnSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDataDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurfaceContainerLow,
        title: Row(
          children: const [
            Icon(Icons.refresh_rounded, color: AppColors.errorMuted),
            SizedBox(width: 8),
            Text(
              'Reset All Data?',
              style: TextStyle(color: AppColors.darkOnSurface),
            ),
          ],
        ),
        content: const Text(
          'This will clear all local storage, erase goals and focus sessions, and return you to the onboarding flow to test from a completely fresh state.',
          style: TextStyle(color: AppColors.darkOnSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorMuted,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref
                  .read(userProfileNotifierProvider.notifier)
                  .resetAllDataAndReplayOnboarding();
            },
            child: const Text(
              'Reset & Replay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      color: AppColors.darkOutlineVariant.withValues(alpha: 0.15),
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
