import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/new_task_dialog.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  int _selectedDayIndex = 3; // Thursday (24)
  bool _isBannerDismissed = false;

  final _days = const [
    {'day': 'M', 'date': '21'},
    {'day': 'T', 'date': '22'},
    {'day': 'W', 'date': '23'},
    {'day': 'Th', 'date': '24'},
    {'day': 'F', 'date': '25'},
    {'day': 'S', 'date': '26'},
    {'day': 'Su', 'date': '27'},
  ];

  void _openAddTaskDialog() {
    HapticFeedback.selectionClick();
    showDialog(
      context: context,
      builder: (context) => const NewTaskDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);
    final timerState = ref.watch(focusTimerNotifierProvider);

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Thursday, Oct 24',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkOnSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'Intentional rhythm • ${tasksState.completedCount} of ${tasksState.totalCount} blocks aligned',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.darkOutline,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openAddTaskDialog,
                        icon: const Icon(
                          Icons.add,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        tooltip: 'Add Time Block',
                      ),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerHigh,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: AppColors.darkOnSurfaceVariant,
                          size: 18,
                        ),
                      ),
                    ],
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
            // Mini-week horizontal pill ribbon
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_days.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  final item = _days[index];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDayIndex = index);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryContainer
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected
                              ? Border.all(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.4),
                                )
                              : null,
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['day']!,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.darkOutline,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item['date']!,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.darkOnSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 14),

            // AI Coach Schedule Suggestion Banner
            if (!_isBannerDismissed) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkOutlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            AppColors.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.tertiary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.nature_people,
                        color: AppColors.tertiary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'MINDFUL CADENCE',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.tertiary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.tertiary.withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Coach Insight',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.darkOutline,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.darkOnSurface,
                                height: 1.3,
                              ),
                              children: [
                                TextSpan(text: 'Notice: You have a '),
                                TextSpan(
                                  text: '45 min buffer',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                TextSpan(
                                    text:
                                        ' after staging deploy. Perfect for a quiet walk.'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.darkOutline,
                        size: 16,
                      ),
                      onPressed: () {
                        setState(() => _isBannerDismissed = true);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Vertical Timeline Flow
            if (tasksState.tasks.isNotEmpty)
              Stack(
              children: [
                // Hairline vertical guide bar
                Positioned(
                  left: 19,
                  top: 20,
                  bottom: 30,
                  child: Container(
                    width: 2,
                    color: AppColors.darkSurfaceContainerHighest,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasksState.tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasksState.tasks[index];
                    final isDone = task.isCompleted;
                    final isFocus = task.isCurrentFocus && !isDone;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live Time Indicator inserted right before active item
                        if (isFocus) _buildLiveTimeIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left timeline node circle
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDone
                                      ? AppColors.successEmerald
                                      : (isFocus
                                          ? AppColors.primary
                                          : AppColors.darkSurfaceContainer),
                                  border: Border.all(
                                    color: isFocus
                                        ? AppColors.primary
                                            .withValues(alpha: 0.3)
                                        : AppColors.darkOutlineVariant
                                            .withValues(alpha: 0.4),
                                    width: isFocus ? 3 : 1,
                                  ),
                                  boxShadow: isFocus
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withValues(alpha: 0.35),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Icon(
                                  isDone
                                      ? Icons.check
                                      : (isFocus
                                          ? Icons.play_arrow
                                          : Icons.radio_button_unchecked),
                                  color: isDone || isFocus
                                      ? Colors.black
                                      : AppColors.darkOutline,
                                  size: isFocus ? 22 : 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Task Card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isFocus
                                        ? AppColors.darkSurfaceContainer
                                        : AppColors.darkSurfaceContainerLow
                                            .withValues(
                                                alpha: isDone ? 0.7 : 1.0),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isFocus
                                          ? AppColors.primary
                                              .withValues(alpha: 0.4)
                                          : AppColors.darkOutlineVariant
                                              .withValues(alpha: 0.25),
                                    ),
                                    boxShadow: isFocus
                                        ? [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${task.scheduledTime} • ${task.durationMinutes}m',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isDone
                                                  ? AppColors.successEmerald
                                                  : (isFocus
                                                      ? AppColors.primary
                                                      : AppColors.darkOutline),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isDone
                                                  ? AppColors.successEmerald
                                                      .withValues(alpha: 0.15)
                                                  : (isFocus
                                                      ? AppColors
                                                          .primaryContainer
                                                      : AppColors
                                                          .darkSurfaceContainerHighest),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              isDone
                                                  ? 'Finished'
                                                  : (isFocus
                                                      ? 'Focus Mode'
                                                      : 'Upcoming'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isDone
                                                    ? AppColors.successEmerald
                                                    : (isFocus
                                                        ? Colors.white
                                                        : AppColors
                                                            .darkOnSurfaceVariant),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        task.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isFocus
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          color: isDone
                                              ? AppColors.darkOutline
                                              : AppColors.darkOnSurface,
                                          decoration: isDone
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      if (task.subtitle.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          task.subtitle,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.darkOutline,
                                          ),
                                        ),
                                      ],
                                      // Active Focus Card controls
                                      if (isFocus) ...[
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.timelapse,
                                                  size: 16,
                                                  color: AppColors.secondary,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  timerState.status ==
                                                          TimerStatus.running
                                                      ? timerState.formattedTime
                                                      : '${task.durationMinutes} min remaining',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            FilledButton.icon(
                                              onPressed: () {
                                                HapticFeedback.mediumImpact();
                                                ref
                                                    .read(tasksNotifierProvider
                                                        .notifier)
                                                    .toggleTask(task.id);
                                              },
                                              icon: const Icon(
                                                Icons.check_circle,
                                                size: 16,
                                              ),
                                              label: const Text('Complete'),
                                              style: FilledButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primary,
                                                foregroundColor: Colors.black,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 14,
                                                  vertical: 8,
                                                ),
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            )
            else
              _buildEmptyTimeline(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTimeIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 12),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 22),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Current Time: 1:45 PM',
                  style: TextStyle(
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
    );
  }

  Widget _buildEmptyTimeline(BuildContext context) {
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
              Icons.calendar_today_outlined,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Scheduled Blocks Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Your day is open and calm. Add focused timeblocks to protect your deep work and intentional rhythm.',
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
                builder: (ctx) => const NewTaskDialog(),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Focus Block'),
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
