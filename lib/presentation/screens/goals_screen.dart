import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../providers/app_providers.dart';
import '../widgets/goal_breakdown_sheet.dart';
import '../widgets/new_goal_dialog.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  bool _isArchiveExpanded = false;

  void _openBreakdown(Goal goal) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GoalBreakdownSheet(goal: goal),
    );
  }

  void _openGoalOptionsSheet(Goal goal) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkOutline.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  goal.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOnSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${goal.category} • Due in ${goal.dueInDays} days',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.darkOutline,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(
                    Icons.account_tree_outlined,
                    color: AppColors.primary,
                  ),
                  title: const Text(
                    'Milestone Breakdown',
                    style: TextStyle(color: AppColors.darkOnSurface),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openBreakdown(goal);
                  },
                ),
                if (!goal.isCompleted && !goal.isTodayMission)
                  ListTile(
                    leading: const Icon(
                      Icons.bolt,
                      color: AppColors.secondary,
                    ),
                    title: const Text(
                      "Set as Today's Mission",
                      style: TextStyle(color: AppColors.darkOnSurface),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(goalsNotifierProvider.notifier)
                          .setTodayMission(goal.id);
                    },
                  ),
                if (!goal.isCompleted)
                  ListTile(
                    leading: const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.successEmerald,
                    ),
                    title: const Text(
                      'Mark as Completed',
                      style: TextStyle(color: AppColors.darkOnSurface),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      ref
                          .read(goalsNotifierProvider.notifier)
                          .completeGoal(goal.id);
                    },
                  ),
                ListTile(
                  leading: const Icon(
                    Icons.archive_outlined,
                    color: AppColors.darkOnSurfaceVariant,
                  ),
                  title: const Text(
                    'Archive Goal',
                    style: TextStyle(color: AppColors.darkOnSurface),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(goalsNotifierProvider.notifier)
                        .archiveGoal(goal.id);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    'Delete Goal',
                    style: TextStyle(color: AppColors.error),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(goalsNotifierProvider.notifier)
                        .deleteGoal(goal.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Deleted "${goal.title}"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openNewGoalDialog() {
    final activeGoals = ref.read(goalsNotifierProvider).activeGoals;
    if (activeGoals.length >= 3) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.darkSurfaceContainerHighest,
          content: Text(
            'Active focus cap reached (3 of 3 slots). Complete or archive an existing goal to maintain calm focus.',
            style: TextStyle(color: AppColors.secondary),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => const NewGoalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalsState = ref.watch(goalsNotifierProvider);
    final activeGoals = goalsState.activeGoals;
    final completedGoals = goalsState.completedGoals;

    Goal? primaryGoal;
    final remainingActive = <Goal>[];

    final missionIndex = activeGoals.indexWhere((g) => g.isTodayMission);
    if (missionIndex != -1) {
      primaryGoal = activeGoals[missionIndex];
      for (int i = 0; i < activeGoals.length; i++) {
        if (i != missionIndex) {
          remainingActive.add(activeGoals[i]);
        }
      }
    } else if (activeGoals.isNotEmpty) {
      primaryGoal = activeGoals.first;
      remainingActive.addAll(activeGoals.sublist(1));
    }

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
                children: [
                  Row(
                    children: [
                      const Text(
                        'Active Goals',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkOnSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${activeGoals.length} of 3 slots',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _openNewGoalDialog,
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    tooltip: 'New Horizon',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Focus on what truly matters this quarter. Quality over quantity.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.darkOnSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),

            // Primary Goal Card
            if (primaryGoal != null) ...[
              _buildPrimaryGoalCard(primaryGoal),
              const SizedBox(height: 16),
            ] else if (remainingActive.isEmpty) ...[
              _buildEmptyGoalsCard(context),
              const SizedBox(height: 16),
            ],

            // Supporting Goals
            if (remainingActive.isNotEmpty) ...[
              Text(
                'Secondary Active Horizons (${remainingActive.length})',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkOutline,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
            ],
            ...remainingActive.map((goal) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildSecondaryGoalCard(goal),
              );
            }),

            // Completed Milestones / Archive Accordion
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
                  InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isArchiveExpanded = !_isArchiveExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: AppColors.primary,
                                  size: 15,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Completed this month',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkOnSurface,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.darkSurfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.darkOutlineVariant
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  '${completedGoals.length}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkOnSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isArchiveExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: AppColors.darkOutline,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isArchiveExpanded)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        children: completedGoals.map((cg) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurfaceContainer,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.darkOutlineVariant
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cg.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.darkOnSurface,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                        Text(
                                          cg.completedAt ?? 'Finished recently',
                                          style: const TextStyle(
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
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.darkSurfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    cg.category,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.darkOutline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // + New Horizon Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: _openNewGoalDialog,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('+ New Horizon'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                    color: AppColors.darkOutlineVariant.withValues(alpha: 0.5),
                  ),
                  backgroundColor: AppColors.darkSurfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryGoalCard(Goal goal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (goal.isTodayMission)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars, color: AppColors.primary, size: 12),
                            SizedBox(width: 4),
                            Text(
                              "Today's Mission",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        goal.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.darkOutline,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Due in ${goal.dueInDays} days',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkOnSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.more_horiz,
                  color: AppColors.darkOutline,
                  size: 20,
                ),
                onPressed: () => _openGoalOptionsSheet(goal),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Visual Banner
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    goal.imageUrl ??
                        'https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?auto=format&fit=crop&w=800&q=80',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.darkSurfaceContainerHigh,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.darkSurfaceContainerLowest
                              .withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainerLow
                            .withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.darkOutlineVariant
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 13,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'On Track',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkOnSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            goal.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkOnSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            goal.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          // Progress Meter Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkOutlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flag, color: AppColors.primary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Milestone 3 of 4: Interactive Showcase',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkOnSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 7,
                    backgroundColor: AppColors.darkSurfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(goalsNotifierProvider.notifier)
                        .setTodayMission(goal.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.darkSurfaceContainerHigh,
                        content: Text(
                          "Set '${goal.title}' as Today's Mission.",
                          style: const TextStyle(color: Colors.white),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.bolt, size: 18),
                  label: const Text("Set Today's Mission"),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.account_tree,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  tooltip: 'View Breakdown',
                  onPressed: () => _openBreakdown(goal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryGoalCard(Goal goal) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openBreakdown(goal),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          goal.category,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:
                              AppColors.tertiaryContainer.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.tertiary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '${goal.streakDays}-day streak',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.more_horiz,
                      color: AppColors.darkOutline,
                      size: 20,
                    ),
                    onPressed: () => _openGoalOptionsSheet(goal),
                  ),
                ],
              ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Micro Progress Ring
              SizedBox(
                width: 50,
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(50, 50),
                      painter: _MicroRingPainter(progress: goal.progress),
                    ),
                    Text(
                      '${(goal.progress * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '4 of 5 sessions logged this week',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.darkOutline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.darkOutlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.spa,
                  size: 16,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '“${goal.affirmation}”',
                    style: const TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: AppColors.darkOnSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildEmptyGoalsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.flag_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Focus Space is Open',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'You have 3 available slots. Focus on what truly matters this quarter. Quality over quantity.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkOnSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const NewGoalDialog(),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Set Your First Goal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MicroRingPainter extends CustomPainter {
  final double progress;

  _MicroRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    final trackPaint = Paint()
      ..color = AppColors.darkSurfaceContainerHighest
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MicroRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
