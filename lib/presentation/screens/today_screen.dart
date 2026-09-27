import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/task_item.dart';
import '../../data/models/goal.dart';
import '../providers/app_providers.dart';
import '../widgets/focus_glyph.dart';
import '../widgets/new_goal_dialog.dart';
import '../widgets/new_task_dialog.dart';

class TodayScreen extends ConsumerWidget {
  final VoidCallback onOpenProfile;

  const TodayScreen({super.key, required this.onOpenProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsNotifierProvider);
    final tasksState = ref.watch(tasksNotifierProvider);
    final timerState = ref.watch(focusTimerNotifierProvider);
    final userProfile = ref.watch(userProfileNotifierProvider);

    final missionGoal = goalsState.todayMission;
    final inFocusTask = tasksState.inFocusTask;

    final completedCount = tasksState.completedCount;
    final totalCount = tasksState.totalCount == 0 ? 5 : tasksState.totalCount;
    final progressFraction = completedCount / totalCount;

    final now = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Good morning' : (hour < 17 ? 'Good afternoon' : 'Good evening');
    final formattedDate = 'Today, ${DateFormat('MMM d').format(now)}';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
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
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0E5FC3).withValues(alpha: 0.4),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Focus',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkOnSurface,
                                    ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'TODAY',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              color: AppColors.darkOutline,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onOpenProfile,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.darkOutlineVariant
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      child: ClipOval(
                        child: userProfile.avatarUrl.startsWith('assets/')
                            ? Image.asset(userProfile.avatarUrl, fit: BoxFit.cover)
                            : Image.network(
                                userProfile.avatarUrl.isNotEmpty
                                    ? userProfile.avatarUrl
                                    : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=150&q=80',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.person,
                                  color: AppColors.darkOnSurface,
                                  size: 20,
                                ),
                              ),
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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Warm Greeting
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$greeting, ${userProfile.name.split(' ').first}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkOnSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('✨', style: TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'You have a fresh, calm day ahead.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.darkOnSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.darkOutlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: ClipOval(
                    child: userProfile.avatarUrl.startsWith('assets/')
                        ? Image.asset(userProfile.avatarUrl, fit: BoxFit.cover)
                        : Image.network(
                            userProfile.avatarUrl.isNotEmpty
                                ? userProfile.avatarUrl
                                : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=150&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.spa,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 2. Today's Mission Hero Card
            if (missionGoal == null)
              _buildEmptyMissionCard(context, ref)
            else
              Container(
                width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Text(
                          "Today's Mission",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              'Day ${missionGoal.streakDays}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              missionGoal.title,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              missionGoal.description,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.darkOutline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Progress Ring
                      SizedBox(
                        width: 58,
                        height: 58,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CustomPaint(
                              size: const Size(58, 58),
                              painter: _SingleRingPainter(
                                progress: progressFraction,
                                strokeColor: AppColors.successEmerald,
                              ),
                            ),
                            Text(
                              '$completedCount/$totalCount',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified,
                        color: AppColors.successEmerald,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          missionGoal.affirmation.isNotEmpty
                              ? '“${missionGoal.affirmation}”'
                              : '“One conscious step at a time.”',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: AppColors.darkOnSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Next Actionable Step Card
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'NEXT STEP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                    letterSpacing: 0.6,
                  ),
                ),
                Text(
                  inFocusTask != null
                      ? 'Step ${inFocusTask.stepNumber} of ${inFocusTask.totalSteps}'
                      : '${tasksState.completedCount} of ${tasksState.tasks.length} done',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkOutline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Container(
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
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 5, color: AppColors.primaryContainer),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer
                                          .withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: const Text(
                                      'In Focus',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.timer,
                                        size: 14,
                                        color: AppColors.darkOutline,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        timerState.status == TimerStatus.running
                                            ? timerState.formattedTime
                                            : '${inFocusTask?.durationMinutes ?? 25} min',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: timerState.status ==
                                                  TimerStatus.running
                                              ? AppColors.primary
                                              : AppColors.darkOutline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          inFocusTask?.title ??
                                              (tasksState.tasks.isEmpty
                                                  ? 'Add your first focus step'
                                                  : 'All steps completed for today! 🎉'),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          inFocusTask?.subtitle ??
                                              (tasksState.tasks.isEmpty
                                                  ? 'Break down your goal into calm micro-steps'
                                                  : 'Great job! Take a quiet rest or review in Evening Ritual'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkOutline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Tactile completion button
                                  InkWell(
                                    onTap: () {
                                      if (inFocusTask != null) {
                                        HapticFeedback.mediumImpact();
                                        ref
                                            .read(tasksNotifierProvider.notifier)
                                            .toggleTask(inFocusTask.id);
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(24),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: inFocusTask?.isCompleted == true
                                            ? AppColors.successEmerald
                                            : AppColors.darkSurfaceContainerHigh,
                                        border: Border.all(
                                          color: inFocusTask?.isCompleted ==
                                                  true
                                              ? AppColors.successEmerald
                                              : AppColors.darkOutlineVariant
                                                  .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        color: inFocusTask?.isCompleted == true
                                            ? Colors.black
                                            : AppColors.darkOutline,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Focus Pomodoro Action Button
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 46,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(24),
                                        gradient: const LinearGradient(
                                          colors: [
                                            AppColors.accentPurpleStart,
                                            AppColors.primaryContainer,
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primaryContainer
                                                .withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          if (timerState.status ==
                                              TimerStatus.running) {
                                            ref
                                                .read(
                                                    focusTimerNotifierProvider
                                                        .notifier)
                                                .pause();
                                          } else {
                                            if (inFocusTask != null &&
                                                (timerState.status ==
                                                        TimerStatus.initial ||
                                                    timerState.taskTitle !=
                                                        inFocusTask.title)) {
                                              ref
                                                  .read(
                                                      focusTimerNotifierProvider
                                                          .notifier)
                                                  .setTaskAndDuration(
                                                    inFocusTask.title,
                                                    inFocusTask.durationMinutes,
                                                    subtitle:
                                                        inFocusTask.subtitle,
                                                  );
                                            }
                                            ref
                                                .read(
                                                    focusTimerNotifierProvider
                                                        .notifier)
                                                .startOrResume();
                                          }
                                        },
                                        icon: Icon(
                                          timerState.status ==
                                                  TimerStatus.running
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                          size: 18,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          timerState.status ==
                                                  TimerStatus.running
                                              ? 'Pause Focus (${timerState.formattedTime})'
                                              : (timerState.status ==
                                                      TimerStatus.paused
                                                  ? 'Resume Focus (${timerState.formattedTime})'
                                                  : (timerState.status ==
                                                          TimerStatus.completed
                                                      ? 'Focus Complete 🎉 Restart'
                                                      : 'Begin ${inFocusTask?.durationMinutes ?? (timerState.totalSeconds ~/ 60)}m Focus')),
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (timerState.status ==
                                          TimerStatus.running ||
                                      timerState.status ==
                                          TimerStatus.paused) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            AppColors.darkSurfaceContainerHigh,
                                        border: Border.all(
                                          color: AppColors.darkOutlineVariant
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: IconButton(
                                        tooltip: 'Reset Timer',
                                        icon: const Icon(
                                          Icons.replay,
                                          color: AppColors.darkOnSurfaceVariant,
                                          size: 18,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.selectionClick();
                                          ref
                                              .read(focusTimerNotifierProvider
                                                  .notifier)
                                              .reset();
                                        },
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          AppColors.darkSurfaceContainerHigh,
                                      border: Border.all(
                                        color: AppColors.darkOutlineVariant
                                            .withValues(alpha: 0.4),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.more_horiz,
                                        color: AppColors.darkOnSurfaceVariant,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        _showDurationPickerSheet(context, ref);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 4. Daily Flow Section (Vertical Timeline Preview)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Daily Flow',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.darkOutlineVariant
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '${tasksState.remainingCount} remaining',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkOutline,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    showDialog(
                      context: context,
                      builder: (ctx) => const NewTaskDialog(),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Add Step',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: tasksState.tasks.isNotEmpty
                  ? ListView.separated(
                      shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tasksState.tasks.length,
                separatorBuilder: (context, index) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final task = tasksState.tasks[index];
                  final isDone = task.isCompleted;
                  final isFocus = task.isCurrentFocus && !isDone;

                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(tasksNotifierProvider.notifier)
                          .toggleTask(task.id);
                    },
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      _showTaskOptionsSheet(context, ref, task);
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? AppColors.successEmerald
                                : (isFocus
                                    ? AppColors.primaryContainer
                                    : AppColors.darkSurfaceContainerHigh),
                            border: Border.all(
                              color: isFocus
                                  ? AppColors.primary
                                  : AppColors.darkOutlineVariant
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Icon(
                            isDone
                                ? Icons.check
                                : (isFocus
                                    ? Icons.radio_button_checked
                                    : Icons.schedule),
                            color: isDone
                                ? Colors.black
                                : (isFocus
                                    ? Colors.white
                                    : AppColors.darkOutline),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isFocus
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isDone
                                            ? AppColors.darkOutline
                                            : (isFocus
                                                ? Colors.white
                                                : AppColors.darkOnSurface),
                                        decoration: isDone
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    isFocus ? 'Now' : task.scheduledTime,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isFocus
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isFocus
                                          ? AppColors.primary
                                          : AppColors.darkOutline,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isDone
                                    ? 'Completed'
                                    : (isFocus
                                        ? 'In progress • Focus active'
                                        : 'Upcoming next'),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDone
                                      ? AppColors.successEmerald
                                      : (isFocus
                                          ? AppColors.primary
                                          : AppColors.darkOutline),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.more_horiz,
                            color: AppColors.darkOutline,
                            size: 16,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _showTaskOptionsSheet(context, ref, task);
                          },
                        ),
                      ],
                    ),
                  );
                },
              )
                  : _buildEmptyDailyFlowCard(
                      context, missionGoal?.id ?? ''),
            ),
            const SizedBox(height: 16),

            // 5. Mindful Guidance AI Coach Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.wb_incandescent,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MINDFUL GUIDANCE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Ready for your next step? Focus block set for 25 mins without notifications. Breathe calmly and let flow take over.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.darkOnSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 6. Visual Atmospheric Photo Tile
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=800&q=80',
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
                                .withValues(alpha: 0.9),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 12,
                      left: 16,
                      child: Text(
                        'Quiet mind. Steady momentum.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkOnSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMissionCard(BuildContext context, WidgetRef ref) {
    final allGoals = ref.watch(goalsNotifierProvider).goals;
    final activeGoals = allGoals.where((g) => !g.isCompleted).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const FocusGlyph(size: 48),
          const SizedBox(height: 14),
          const Text(
            'No Mission Active Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Select your primary mission from Active Goals or craft a new goal to anchor your day.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.darkOnSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              if (activeGoals.isNotEmpty)
                ElevatedButton.icon(
                  onPressed: () {
                    _showGoalSelectorSheet(context, ref, activeGoals);
                  },
                  icon: const Icon(Icons.stars, size: 18),
                  label: const Text("Choose Today's Mission"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const NewGoalDialog(),
                  );
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Goal'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showGoalSelectorSheet(
      BuildContext context, WidgetRef ref, List<Goal> activeGoals) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkOutlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Choose Today's Mission",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOnSurface,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Select the single active goal to anchor your focus today.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkOutline,
                  ),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: activeGoals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final goal = activeGoals[index];
                      return ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        tileColor: AppColors.darkSurfaceContainerHigh,
                        leading: const Icon(Icons.stars, color: AppColors.primary),
                        title: Text(
                          goal.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          goal.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.darkOutline,
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 14, color: AppColors.darkOutline),
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          ref
                              .read(goalsNotifierProvider.notifier)
                              .setTodayMission(goal.id);
                          Navigator.pop(ctx);
                        },
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

  Widget _buildEmptyDailyFlowCard(BuildContext context, String goalId) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(
            Icons.schedule_outlined,
            color: AppColors.primary,
            size: 32,
          ),
          const SizedBox(height: 10),
          const Text(
            'Daily Flow is Open',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Add 1 to 3 focus steps to guide your day without feeling overwhelmed.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.darkOnSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => const NewTaskDialog(),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Focus Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDurationPickerSheet(BuildContext context, WidgetRef ref) {
    final timerNotifier = ref.read(focusTimerNotifierProvider.notifier);
    final timerState = ref.read(focusTimerNotifierProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          AppColors.darkOutlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Focus Session Cadence',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose an intentional focus block for this task.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.darkOutline,
                  ),
                ),
                const SizedBox(height: 16),
                ...[
                  {
                    'min': 15,
                    'label': '15 min',
                    'desc': 'Quick Sprint — Clear immediate friction'
                  },
                  {
                    'min': 25,
                    'label': '25 min',
                    'desc': 'Standard Block — Optimal flow & calm'
                  },
                  {
                    'min': 45,
                    'label': '45 min',
                    'desc': 'Deep Work — Complex creation & coding'
                  },
                  {
                    'min': 60,
                    'label': '60 min',
                    'desc': 'Deep Immersion — Uninterrupted flow'
                  },
                ].map((item) {
                  final minutes = item['min'] as int;
                  final isCurrent = timerState.totalSeconds ~/ 60 == minutes;
                  return InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      timerNotifier.setDuration(minutes);
                      Navigator.pop(ctx);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.primaryContainer.withValues(alpha: 0.3)
                            : AppColors.darkSurfaceContainerHigh
                                .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.primary
                              : AppColors.darkOutlineVariant
                                  .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_off,
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.darkOutline,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? Colors.white
                                        : AppColors.darkOnSurface,
                                  ),
                                ),
                                Text(
                                  item['desc'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkOutline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                if (timerState.status != TimerStatus.initial)
                  OutlinedButton.icon(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      timerNotifier.reset();
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.restart_alt, size: 16),
                    label: const Text('Reset Active Timer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.darkOutline,
                      side: BorderSide(
                        color: AppColors.darkOutlineVariant
                            .withValues(alpha: 0.4),
                      ),
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTaskOptionsSheet(
      BuildContext context, WidgetRef ref, TaskItem task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          AppColors.darkOutlineVariant.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (task.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.darkOutline,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.play_circle_outline,
                      color: AppColors.primary),
                  title: const Text('Set as Active Focus Step',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .setFocusTask(task.id);
                    ref
                        .read(focusTimerNotifierProvider.notifier)
                        .setTaskAndDuration(
                          task.title,
                          task.durationMinutes,
                          subtitle: task.subtitle,
                        );
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: Icon(
                    task.isCompleted
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: AppColors.successEmerald,
                  ),
                  title: Text(
                    task.isCompleted
                        ? 'Mark as Incomplete'
                        : 'Mark as Completed',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .toggleTask(task.id);
                    Navigator.pop(ctx);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline,
                      color: AppColors.errorMuted),
                  title: const Text('Delete Step',
                      style: TextStyle(color: AppColors.errorMuted)),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .deleteTask(task.id);
                    Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


class _SingleRingPainter extends CustomPainter {
  final double progress;
  final Color strokeColor;

  _SingleRingPainter({required this.progress, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final trackPaint = Paint()
      ..color = AppColors.darkSurfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
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
  bool shouldRepaint(covariant _SingleRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeColor != strokeColor;
}
