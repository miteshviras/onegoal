import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/evening_ritual_card.dart';
import '../widgets/progress_rings_painter.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  void _showAllBadgesDialog(BuildContext context, WidgetRef ref) {
    HapticFeedback.selectionClick();
    final progress = ref.read(progressNotifierProvider);
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.darkSurfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quiet Milestones (12)',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.darkOutline,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Gentle markers of self-trust, never gamified or anxious.',
                  style: TextStyle(fontSize: 12, color: AppColors.darkOutline),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: progress.milestones.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final badge = progress.milestones[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: badge.isUnlocked
                                ? AppColors.primary.withValues(alpha: 0.3)
                                : AppColors.darkOutlineVariant.withValues(
                                    alpha: 0.2,
                                  ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: badge.isUnlocked
                                    ? AppColors.primaryContainer.withValues(
                                        alpha: 0.4,
                                      )
                                    : AppColors.darkSurfaceContainerHigh,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getBadgeIcon(badge.iconKey),
                                color: badge.isUnlocked
                                    ? AppColors.primary
                                    : AppColors.darkOutline,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    badge.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkOnSurface,
                                    ),
                                  ),
                                  Text(
                                    badge.subtitle,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.darkOutline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: badge.isUnlocked
                                    ? AppColors.successEmerald.withValues(
                                        alpha: 0.15,
                                      )
                                    : AppColors.darkSurfaceContainerHighest,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                badge.isUnlocked ? 'Unlocked' : 'In Progress',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: badge.isUnlocked
                                      ? AppColors.successEmerald
                                      : AppColors.darkOutline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static IconData _getBadgeIcon(String key) {
    switch (key) {
      case 'psychology':
        return Icons.psychology;
      case 'eco':
        return Icons.eco;
      case 'done_all':
        return Icons.done_all;
      case 'light_mode':
        return Icons.light_mode;
      case 'bedtime':
        return Icons.bedtime;
      default:
        return Icons.workspace_premium;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressNotifierProvider);
    final userProfile = ref.watch(userProfileNotifierProvider);
    final tasksState = ref.watch(tasksNotifierProvider);

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
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.successEmerald.withValues(
                        alpha: 0.15,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.spa,
                      color: AppColors.successEmerald,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'WEEKLY RHYTHM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOutline,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showAllBadgesDialog(context, ref),
                    child: const Text(
                      'All 12 Badges',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header statement
            Text(
              tasksState.completedCount > 0
                  ? 'You completed ${tasksState.completedCount} of ${tasksState.totalCount} focus steps'
                  : 'Intentional rhythm awaits',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkOnSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Calm, steady momentum. No streaks to fear losing, just evidence of your commitment.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Apple Health Style Triple Rings Bento
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Concentric rings
                      TripleProgressRings(
                        missionsProgress: progress.missionsProgress,
                        habitsProgress: progress.habitsProgress,
                        focusHoursProgress: progress.focusHoursProgress,
                        harmonyPercentage: (progress.harmonyScore * 100)
                            .toInt(),
                        size: 130,
                      ),
                      const SizedBox(width: 14),
                      // Ring breakdown legends
                      Expanded(
                        child: Column(
                          children: [
                            _buildLegendItem(
                              color: AppColors.primary,
                              title: 'Daily Missions',
                              subtitle:
                                  '${tasksState.completedCount} completed steps',
                              value:
                                  '${(progress.missionsProgress * 100).toInt()}%',
                            ),
                            const SizedBox(height: 8),
                            _buildLegendItem(
                              color: AppColors.successEmerald,
                              title: 'Habit Consistency',
                              subtitle: '5 of 6 active days',
                              value:
                                  '${(progress.habitsProgress * 100).toInt()}%',
                            ),
                            const SizedBox(height: 8),
                            _buildLegendItem(
                              color: AppColors.tertiary,
                              title: 'Intentional Focus',
                              subtitle:
                                  '${progress.formattedFocusHours} recorded hours',
                              value:
                                  '${(progress.focusHoursProgress * 100).toInt()}%',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick stats bar
                  Row(
                    children: [
                      Expanded(
                        child: _buildMiniStat(
                          'Completion',
                          '${(progress.missionsProgress * 100).toInt()}%',
                          AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniStat(
                          'Deep Work',
                          '${progress.formattedFocusHours}h',
                          AppColors.tertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildMiniStat(
                          'Next Steps',
                          '${tasksState.completedCount} done',
                          AppColors.successEmerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Identity & Mindset Affirmation Card (Gradient)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryContainer,
                    AppColors.secondaryContainer,
                    Color(0xFF1A2D52),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceContainerLowest
                                .withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.15),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.verified,
                                color: AppColors.tertiary,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'Level ${userProfile.level} • ${userProfile.levelTitle}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerLowest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Score ',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              '${userProfile.score}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '“You are becoming someone who executes with clarity and consistency.”',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Daily identity reinforcement • 18 days conscious momentum',
                    style: TextStyle(fontSize: 11, color: AppColors.secondary),
                  ),
                  const SizedBox(height: 12),
                  // Evolution Bar
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Current Evolution',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.darkOnSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${userProfile.pointsToNextLevel} points to Level ${userProfile.level + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: userProfile.evolutionProgress,
                      minHeight: 6,
                      backgroundColor: Colors.black.withValues(alpha: 0.4),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.successEmerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Daily Insight Visual Section
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  color: AppColors.darkSurfaceContainerHigh,
                                ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.darkSurfaceContainerLow,
                                  AppColors.darkSurfaceContainerLow.withValues(
                                    alpha: 0.3,
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurfaceContainerHighest
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Daily Insight',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkOnSurface,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurfaceContainerHighest
                                        .withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Quiet Focus',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.darkOutline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Effort feels lighter when rhythm takes over',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You scheduled fewer fragmented meetings this week. This gave your highest value priorities room to breathe.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkOutline,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Evening Ritual / Reflection Card
            const EveningRitualCard(),
            const SizedBox(height: 16),

            // Quiet Milestones Badges Section
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Quiet Milestones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkOnSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Proof of self-trust built over time',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkOutline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => _showAllBadgesDialog(context, ref),
                  child: const Text(
                    'All 12 Badges',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: progress.milestones.take(3).map((badge) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.darkOutlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: badge.iconKey == 'eco'
                                ? AppColors.successEmerald.withValues(
                                    alpha: 0.2,
                                  )
                                : (badge.iconKey == 'done_all'
                                      ? AppColors.tertiaryContainer.withValues(
                                          alpha: 0.3,
                                        )
                                      : AppColors.primaryContainer.withValues(
                                          alpha: 0.4,
                                        )),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getBadgeIcon(badge.iconKey),
                            color: badge.iconKey == 'eco'
                                ? AppColors.successEmerald
                                : (badge.iconKey == 'done_all'
                                      ? AppColors.tertiary
                                      : AppColors.primary),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkOnSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          badge.subtitle,
                          style: const TextStyle(
                            fontSize: 9,
                            color: AppColors.darkOutline,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: badge.iconKey == 'eco'
                                ? AppColors.successEmerald.withValues(
                                    alpha: 0.15,
                                  )
                                : AppColors.darkSurfaceContainerHighest,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge.iconKey == 'eco' ? 'Achieved' : 'Unlocked',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: badge.iconKey == 'eco'
                                  ? AppColors.successEmerald
                                  : AppColors.darkOnSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String title,
    required String subtitle,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOnSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.darkOutline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.darkOutline),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
