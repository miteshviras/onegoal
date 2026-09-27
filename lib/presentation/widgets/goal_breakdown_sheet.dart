import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../providers/app_providers.dart';

class GoalBreakdownSheet extends ConsumerWidget {
  final Goal goal;

  const GoalBreakdownSheet({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch latest state of this goal
    final goalsState = ref.watch(goalsNotifierProvider);
    final currentGoal = goalsState.goals.firstWhere(
      (g) => g.id == goal.id,
      orElse: () => goal,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: AppColors.darkSurfaceContainer,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.darkOutline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  currentGoal.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                'Due in ${currentGoal.dueInDays} days',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.darkOutline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            currentGoal.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            currentGoal.description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.darkOnSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Milestone Breakdown',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    '${(currentGoal.progress * 100).toInt()}%',
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
                  value: currentGoal.progress,
                  minHeight: 6,
                  backgroundColor: AppColors.darkSurfaceContainerHighest,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentGoal.milestones.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final milestone = currentGoal.milestones[index];
                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(goalsNotifierProvider.notifier).toggleMilestone(
                          currentGoal.id,
                          milestone.id,
                        );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: milestone.isCompleted
                            ? AppColors.successEmerald.withValues(alpha: 0.3)
                            : AppColors.darkOutlineVariant
                                .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          milestone.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: milestone.isCompleted
                              ? AppColors.successEmerald
                              : AppColors.darkOutline,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            milestone.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: milestone.isCompleted
                                  ? AppColors.darkOutline
                                  : AppColors.darkOnSurface,
                              decoration: milestone.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        if (milestone.completedAt != null)
                          Text(
                            milestone.completedAt!,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.darkOutline,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          if (!currentGoal.isTodayMission)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  ref
                      .read(goalsNotifierProvider.notifier)
                      .setTodayMission(currentGoal.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.bolt, size: 18),
                label: const Text("Set as Today's Mission"),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
