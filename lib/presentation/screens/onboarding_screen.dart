import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/goal.dart';
import '../../data/models/task_item.dart';
import '../providers/app_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Step 2 state (Profile Customization)
  final TextEditingController _nameController =
      TextEditingController(text: '');
  final TextEditingController _titleController =
      TextEditingController(text: '');
  String _selectedAvatar = 'assets/images/app_logo.png';
  String _coachingTone = 'gentle'; // 'gentle' | 'concise'
  String _morningTime = '08:30 AM';
  String _eveningTime = '08:30 PM';
  int _focusDuration = 25;

  final List<Map<String, String>> _avatarPresets = [
    {
      'label': 'Orbit',
      'url': 'assets/images/app_logo.png',
      'isAsset': 'true',
    },
    {
      'label': 'Zen',
      'url':
          'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Creator',
      'url':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Builder',
      'url':
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Focus',
      'url':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
  ];

  final List<String> _roleSuggestions = [
    'Founder',
    'Software Engineer',
    'Product Designer',
    'Creator',
    'Researcher',
    'Writer',
  ];

  // Step 3 state (Permissions)
  bool _notificationsAllowed = true;
  bool _timerChimesAllowed = true;

  // Step 4 state (First Goal)
  final TextEditingController _goalTitleController =
      TextEditingController(text: 'Launch MVP');
  final TextEditingController _firstStepController =
      TextEditingController(text: 'Define core user journey');
  String _selectedCategory = 'Career & Craft';
  int _targetDays = 14;

  final List<String> _categories = [
    'Career & Craft',
    'Health & Energy',
    'Creative',
    'Life Ops',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _titleController.dispose();
    _goalTitleController.dispose();
    _firstStepController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime({required bool isMorning}) async {
    final initial = isMorning
        ? const TimeOfDay(hour: 8, minute: 30)
        : const TimeOfDay(hour: 20, minute: 30);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.fidelityDarkAccent,
              surface: AppColors.fidelityDarkCard,
              onSurface: AppColors.fidelityDarkText,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      final formatted = _formatTimeOfDay(picked);
      setState(() {
        if (isMorning) {
          _morningTime = formatted;
        } else {
          _eveningTime = formatted;
        }
      });
    }
  }

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim().isEmpty
        ? 'Alex Rivera'
        : _nameController.text.trim();
    final title = _titleController.text.trim().isEmpty
        ? 'Intentional Builder'
        : _titleController.text.trim();

    // 1. Create First Goal if title provided
    final goalTitle = _goalTitleController.text.trim();
    if (goalTitle.isNotEmpty) {
      const uuid = Uuid();
      final goalId = 'goal_${uuid.v4().substring(0, 8)}';
      final firstStep = _firstStepController.text.trim();

      final initialMilestone = firstStep.isNotEmpty
          ? [GoalMilestone(id: uuid.v4().substring(0, 8), title: firstStep)]
          : <GoalMilestone>[];

      final newGoal = Goal(
        id: goalId,
        title: goalTitle,
        description: 'Primary quarterly focus mission',
        category: _selectedCategory,
        dueInDays: _targetDays,
        isTodayMission: true,
        affirmation: 'You are becoming someone who finishes what they start.',
        milestones: initialMilestone,
      );

      await ref.read(goalRepositoryProvider).addGoal(newGoal);
      await ref.read(goalsProvider.notifier).loadGoals();

      // 2. Add first task in Daily Flow
      if (firstStep.isNotEmpty) {
        final task = TaskItem(
          id: 'task_${uuid.v4().substring(0, 8)}',
          goalId: goalId,
          title: firstStep,
          subtitle: 'First intentional step toward $goalTitle',
          scheduledTime: _morningTime,
          durationMinutes: _focusDuration,
          isCurrentFocus: true,
          order: 1,
          stepNumber: 1,
          totalSteps: 1,
        );
        await ref.read(taskRepositoryProvider).addTask(task);
        await ref.read(todayTasksProvider.notifier).loadTasks();
      }
    }

    // 3. Complete User Profile with customized data
    await ref.read(userProfileNotifierProvider.notifier).completeOnboarding(
          name: name,
          title: title,
          avatarUrl: _selectedAvatar,
          coachingTone: _coachingTone,
          eveningTime: _eveningTime,
          focusDuration: _focusDuration,
          calmNotifications: _notificationsAllowed,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fidelityDarkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with progress indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Row(
                    children: List.generate(4, (index) {
                      final isActive = index <= _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        width: index == _currentPage ? 28 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.fidelityDarkAccent
                              : AppColors.fidelityDarkMutedText.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Back',
                        style: GoogleFonts.manrope(
                          color: AppColors.fidelityDarkMutedText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (_currentPage < 3)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.manrope(
                          color: AppColors.fidelityDarkMutedText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) {
                  setState(() => _currentPage = page);
                },
                children: [
                  _buildPhilosophyStep(),
                  _buildIdentityStep(),
                  _buildPermissionsStep(),
                  _buildFirstMissionStep(),
                ],
              ),
            ),

            // Bottom Action Bar
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.fidelityDarkAccent,
                        Color(0xFF2563EB),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.fidelityDarkAccent.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _currentPage == 3
                          ? 'Enter Focus Sanctuary ✨'
                          : 'Continue',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SLIDE 1: The OneGoal Philosophy
  Widget _buildPhilosophyStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0E5FC3).withValues(alpha: 0.45),
                    blurRadius: 28,
                    spreadRadius: 4,
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
          ),
          const SizedBox(height: 32),
          Text(
            'Calm Focus.\nNot Endless Lists.',
            style: GoogleFonts.manrope(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.fidelityDarkText,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Traditional planners overwhelm you with 20 items and red notification anxiety. OneGoal anchors your day on a single primary mission.',
            style: GoogleFonts.manrope(
              fontSize: 15,
              color: AppColors.fidelityDarkMutedText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),

          _buildPhilosophyPillar(
            icon: Icons.filter_1_rounded,
            title: 'The Rule of One',
            description:
                'One daily mission anchors your focus. If you only accomplish this, your day is a triumph.',
            color: AppColors.fidelityCyan,
          ),
          const SizedBox(height: 16),
          _buildPhilosophyPillar(
            icon: Icons.lock_outline_rounded,
            title: '3-Slot Active Ceiling',
            description:
                'Strict cap of 3 active goals. Prevent multi-project overload and fragmented attention.',
            color: AppColors.fidelityDarkAccent,
          ),
          const SizedBox(height: 16),
          _buildPhilosophyPillar(
            icon: Icons.spa_outlined,
            title: 'Zero-Guilt Rescheduling',
            description:
                'Life has surprises. Roll steps forward effortlessly with zero shame badges.',
            color: AppColors.fidelityEmerald,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPhilosophyPillar({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fidelityDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fidelityDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.fidelityDarkMutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SLIDE 2: Identity & Rhythm
  Widget _buildIdentityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Personalize Your Profile',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.fidelityDarkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your avatar, rhythm, and companion coaching tone.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 24),

          // 1. Choose Avatar
          Text(
            'CHOOSE YOUR AVATAR',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _avatarPresets.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final preset = _avatarPresets[index];
                final isSelected = _selectedAvatar == preset['url'];
                final isAsset = preset['isAsset'] == 'true';

                return GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = preset['url']!),
                  child: Column(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.fidelityDarkAccent
                                : AppColors.fidelityDarkBorder
                                    .withValues(alpha: 0.5),
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.fidelityDarkAccent
                                        .withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: ClipOval(
                          child: isAsset
                              ? Image.asset(preset['url']!, fit: BoxFit.cover)
                              : Image.network(
                                  preset['url']!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person,
                                          color: AppColors.fidelityDarkAccent),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preset['label']!,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.fidelityDarkAccent
                              : AppColors.fidelityDarkMutedText,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // 2. Name
          Text(
            'YOUR NAME',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: GoogleFonts.manrope(color: AppColors.fidelityDarkText),
            decoration: InputDecoration(
              hintText: 'Enter your name (e.g. Alex Rivera)',
              hintStyle: GoogleFonts.manrope(
                color: AppColors.fidelityDarkMutedText.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.person_outline,
                  color: AppColors.fidelityDarkMutedText),
              filled: true,
              fillColor: AppColors.fidelityDarkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Role / Craft with suggestions
          Text(
            'ROLE / CRAFT',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            style: GoogleFonts.manrope(color: AppColors.fidelityDarkText),
            decoration: InputDecoration(
              hintText: 'e.g. Designer, Software Engineer, Founder',
              hintStyle: GoogleFonts.manrope(
                color: AppColors.fidelityDarkMutedText.withValues(alpha: 0.6),
              ),
              prefixIcon: const Icon(Icons.workspace_premium_outlined,
                  color: AppColors.fidelityDarkMutedText),
              filled: true,
              fillColor: AppColors.fidelityDarkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: _roleSuggestions.map((role) {
              final isMatch = _titleController.text == role;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _titleController.text = role;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isMatch
                        ? AppColors.fidelityDarkAccent.withValues(alpha: 0.2)
                        : AppColors.fidelityDarkCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isMatch
                          ? AppColors.fidelityDarkAccent
                          : AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    role,
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: isMatch ? FontWeight.w700 : FontWeight.w500,
                      color: isMatch
                          ? AppColors.fidelityDarkAccent
                          : AppColors.fidelityDarkMutedText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // 4. Companion Coaching Tone
          Text(
            'COMPANION COACHING TONE',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildToneCard(
                tone: 'gentle',
                title: 'Supportive & Gentle',
                subtitle: 'Mindful nudges, positive reinforcement',
                icon: Icons.favorite_rounded,
              ),
              const SizedBox(width: 10),
              _buildToneCard(
                tone: 'concise',
                title: 'Direct & Concise',
                subtitle: 'Action-first, minimal text, direct cues',
                icon: Icons.bolt_rounded,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. Focus Sprint Length
          Text(
            'FOCUS SPRINT LENGTH',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildDurationChip(25, '25m Pomodoro'),
              const SizedBox(width: 8),
              _buildDurationChip(45, '45m Deep Work'),
              const SizedBox(width: 8),
              _buildDurationChip(60, '60m Flow'),
            ],
          ),
          const SizedBox(height: 24),

          // 6. Daily Rhythms with actual TimePicker
          Text(
            'DAILY RHYTHMS',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          _buildTimeRow('Morning Planning', _morningTime, () {
            _pickTime(isMorning: true);
          }),
          const SizedBox(height: 10),
          _buildTimeRow('Evening Reflection', _eveningTime, () {
            _pickTime(isMorning: false);
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildToneCard({
    required String tone,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _coachingTone == tone;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _coachingTone = tone),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.fidelityDarkAccent.withValues(alpha: 0.15)
                : AppColors.fidelityDarkCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.fidelityDarkAccent
                  : AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.fidelityDarkAccent
                        : AppColors.fidelityDarkMutedText,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : AppColors.fidelityDarkText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: AppColors.fidelityDarkMutedText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationChip(int minutes, String label) {
    final isSelected = _focusDuration == minutes;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _focusDuration = minutes),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.fidelityDarkAccent
                : AppColors.fidelityDarkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.fidelityDarkAccent
                  : AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.fidelityDarkMutedText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.fidelityDarkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: AppColors.fidelityDarkMutedText,
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: AppColors.fidelityDarkText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.fidelityDarkAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    value,
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.fidelityDarkAccent,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: AppColors.fidelityDarkAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SLIDE 3: Mindful Permissions
  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Quiet Permissions',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.fidelityDarkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We protect your headspace with zero marketing noise and zero spam.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 28),

          _buildPermissionToggle(
            icon: Icons.notifications_none_rounded,
            title: 'Quiet Daily Nudges',
            description:
                'Morning check-in at 8:30 AM to set today’s mission, and evening wind-down ritual review.',
            value: _notificationsAllowed,
            color: AppColors.fidelityCyan,
            onChanged: (val) => setState(() => _notificationsAllowed = val),
          ),
          const SizedBox(height: 16),
          _buildPermissionToggle(
            icon: Icons.timer_outlined,
            title: 'Tibetan Focus Chime',
            description:
                'Play a gentle singing bowl chime and soothing haptic pulse when your 25-minute sprint ends.',
            value: _timerChimesAllowed,
            color: AppColors.fidelityEmerald,
            onChanged: (val) => setState(() => _timerChimesAllowed = val),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fidelityDarkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.fidelityEmerald.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.fidelityEmerald,
                  size: 26,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attention Sanctuary Guarantee',
                        style: GoogleFonts.manrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.fidelityDarkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Offline-first privacy • Zero data collection • Zero red unread badge anxiety.',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: AppColors.fidelityDarkMutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Color color,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.fidelityDarkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.fidelityDarkText,
                      ),
                    ),
                    Switch(
                      value: value,
                      onChanged: onChanged,
                      activeThumbColor: color,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: AppColors.fidelityDarkMutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SLIDE 4: First Mission Creation
  Widget _buildFirstMissionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Text(
            'Your First Mission',
            style: GoogleFonts.manrope(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.fidelityDarkText,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What is the single most important goal you wish to move forward?',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'PRIMARY GOAL TITLE',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _goalTitleController,
            style: GoogleFonts.manrope(color: AppColors.fidelityDarkText),
            decoration: InputDecoration(
              hintText: 'e.g. Launch Mobile App MVP',
              prefixIcon: const Icon(Icons.flag_outlined,
                  color: AppColors.fidelityDarkMutedText),
              filled: true,
              fillColor: AppColors.fidelityDarkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'CATEGORY',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              return ChoiceChip(
                label: Text(
                  category,
                  style: GoogleFonts.manrope(
                    color: isSelected
                        ? Colors.white
                        : AppColors.fidelityDarkMutedText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.fidelityDarkAccent,
                backgroundColor: AppColors.fidelityDarkCard,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.fidelityDarkAccent
                      : AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
                ),
                onSelected: (val) {
                  if (val) setState(() => _selectedCategory = category);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Text(
            'TARGET HORIZON',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [7, 14, 30].map((days) {
              final isSelected = _targetDays == days;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _targetDays = days),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.fidelityDarkAccent
                            : AppColors.fidelityDarkCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.fidelityDarkAccent
                              : AppColors.fidelityDarkBorder.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$days Days',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.fidelityDarkMutedText,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          Text(
            'FIRST ACTIONABLE STEP FOR TODAY',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.fidelityDarkMutedText,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _firstStepController,
            style: GoogleFonts.manrope(color: AppColors.fidelityDarkText),
            decoration: InputDecoration(
              hintText: 'e.g. Outline architecture & tech stack',
              prefixIcon: const Icon(Icons.check_circle_outline,
                  color: AppColors.fidelityDarkMutedText),
              filled: true,
              fillColor: AppColors.fidelityDarkCard,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                    color: AppColors.fidelityDarkBorder.withValues(alpha: 0.5)),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
