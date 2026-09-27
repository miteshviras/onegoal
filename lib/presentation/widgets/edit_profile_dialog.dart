import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/user_profile.dart';
import '../providers/app_providers.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  static Future<void> show(BuildContext context, UserProfile profile) {
    HapticFeedback.mediumImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditProfileSheet(profile: profile),
    );
  }

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _titleController;
  late final TextEditingController _customAvatarController;

  late String _selectedAvatar;
  late String _coachingTone;
  late String _eveningTime;
  late int _focusDuration;
  bool _showCustomUrlField = false;

  final List<Map<String, String>> _avatarPresets = [
    {'label': 'Orbit', 'url': 'assets/images/app_logo.png', 'isAsset': 'true'},
    {
      'label': 'Zen',
      'url': 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Creator',
      'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Builder',
      'url': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      'isAsset': 'false',
    },
    {
      'label': 'Focus',
      'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
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
    'Student',
  ];

  final List<int> _focusOptions = [15, 20, 25, 30, 45, 50, 60];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _titleController = TextEditingController(text: widget.profile.title);
    _selectedAvatar = widget.profile.avatarUrl.isNotEmpty
        ? widget.profile.avatarUrl
        : 'assets/images/app_logo.png';
    _customAvatarController = TextEditingController(
      text: _selectedAvatar.startsWith('http') ? _selectedAvatar : '',
    );
    _coachingTone = widget.profile.coachingTone;
    _eveningTime = widget.profile.eveningRitualTime;
    _focusDuration = widget.profile.focusTimerMinutes;

    final isPreset = _avatarPresets.any(
      (preset) => preset['url'] == _selectedAvatar,
    );
    if (!isPreset && _selectedAvatar.isNotEmpty) {
      _showCustomUrlField = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _customAvatarController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickEveningTime() async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 30),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurfaceContainer,
              onSurface: AppColors.darkOnSurface,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _eveningTime = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final customUrl = _customAvatarController.text.trim();
    final finalAvatar = (_showCustomUrlField && customUrl.isNotEmpty)
        ? customUrl
        : _selectedAvatar;

    HapticFeedback.mediumImpact();
    await ref
        .read(userProfileNotifierProvider.notifier)
        .updateProfile(
          name: name,
          title: title.isNotEmpty ? title : 'Intentional Builder',
          avatarUrl: finalAvatar,
          coachingTone: _coachingTone,
          eveningRitualTime: _eveningTime,
          focusTimerMinutes: _focusDuration,
        );

    // Also update focus timer if duration changed
    ref
        .read(focusTimerNotifierProvider.notifier)
        .setTaskAndDuration(
          ref.read(tasksNotifierProvider).inFocusTask?.title ??
              'Deep Focus Sprint',
          _focusDuration,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully ✨'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle & Header
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.darkOutlineVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Profile',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkOnSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.darkOutline),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkSurfaceContainerHigh),

          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 16, 20, keyboardInset + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Live Avatar Preview & Camera Edit Action
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 16,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _selectedAvatar.startsWith('assets/')
                                ? Image.asset(
                                    _selectedAvatar,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    _selectedAvatar.isNotEmpty
                                        ? _selectedAvatar
                                        : 'https://images.unsplash.com/photo-1544717305-2782549b5136?auto=format&fit=crop&w=200&q=80',
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(
                                              Icons.person,
                                              color: AppColors.primary,
                                              size: 44,
                                            ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.darkBackground,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Avatar Presets
                  Text(
                    'CHOOSE AVATAR PRESET',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _avatarPresets.length + 1,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        if (index == _avatarPresets.length) {
                          // Custom photo URL option
                          final isCustomSelected = _showCustomUrlField;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _showCustomUrlField = true;
                                if (_customAvatarController.text.isNotEmpty) {
                                  _selectedAvatar = _customAvatarController.text
                                      .trim();
                                }
                              });
                            },
                            child: Column(
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.darkSurfaceContainerHigh,
                                    border: Border.all(
                                      color: isCustomSelected
                                          ? AppColors.primary
                                          : AppColors.darkOutlineVariant,
                                      width: isCustomSelected ? 2.5 : 1.2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.link,
                                    color: isCustomSelected
                                        ? AppColors.primary
                                        : AppColors.darkOutline,
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Custom',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: isCustomSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isCustomSelected
                                        ? AppColors.primary
                                        : AppColors.darkOutline,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final preset = _avatarPresets[index];
                        final isSelected =
                            !_showCustomUrlField &&
                            _selectedAvatar == preset['url'];
                        final isAsset = preset['isAsset'] == 'true';

                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _showCustomUrlField = false;
                              _selectedAvatar = preset['url']!;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.darkOutlineVariant
                                              .withValues(alpha: 0.5),
                                    width: isSelected ? 2.5 : 1.2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withValues(
                                              alpha: 0.4,
                                            ),
                                            blurRadius: 10,
                                            spreadRadius: 1,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: ClipOval(
                                  child: isAsset
                                      ? Image.asset(
                                          preset['url']!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.network(
                                          preset['url']!,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const Icon(
                                                    Icons.person,
                                                    color: AppColors.primary,
                                                  ),
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
                                      ? AppColors.primary
                                      : AppColors.darkOutline,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Custom URL input field
                  if (_showCustomUrlField) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customAvatarController,
                      style: GoogleFonts.manrope(
                        color: AppColors.darkOnSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Custom Photo URL',
                        labelStyle: const TextStyle(
                          color: AppColors.darkOutline,
                        ),
                        hintText: 'https://example.com/avatar.jpg',
                        hintStyle: TextStyle(
                          color: AppColors.darkOutline.withValues(alpha: 0.6),
                        ),
                        prefixIcon: const Icon(
                          Icons.image_outlined,
                          color: AppColors.darkOutline,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.check,
                            color: AppColors.primary,
                          ),
                          onPressed: () {
                            if (_customAvatarController.text
                                .trim()
                                .isNotEmpty) {
                              setState(() {
                                _selectedAvatar = _customAvatarController.text
                                    .trim();
                              });
                            }
                          },
                        ),
                        filled: true,
                        fillColor: AppColors.darkSurfaceContainerLow,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: AppColors.darkOutlineVariant.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.trim().isNotEmpty) {
                          setState(() {
                            _selectedAvatar = val.trim();
                          });
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 3. Name Field
                  Text(
                    'YOUR NAME',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: GoogleFonts.manrope(
                      color: AppColors.darkOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Mitesh Viras',
                      hintStyle: TextStyle(
                        color: AppColors.darkOutline.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.person_outline,
                        color: AppColors.darkOutline,
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.darkOutlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.darkOutlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. Role / Craft Field
                  Text(
                    'ROLE / CRAFT',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    style: GoogleFonts.manrope(
                      color: AppColors.darkOnSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'e.g. Software Engineer, Designer',
                      hintStyle: TextStyle(
                        color: AppColors.darkOutline.withValues(alpha: 0.6),
                      ),
                      prefixIcon: const Icon(
                        Icons.workspace_premium_outlined,
                        color: AppColors.darkOutline,
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.darkOutlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: AppColors.darkOutlineVariant.withValues(
                            alpha: 0.4,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Role suggestion chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _roleSuggestions.map((role) {
                      final isSelected =
                          _titleController.text.trim().toLowerCase() ==
                          role.toLowerCase();
                      return ActionChip(
                        label: Text(role),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkOnSurfaceVariant,
                        ),
                        backgroundColor: isSelected
                            ? AppColors.primaryContainer.withValues(alpha: 0.4)
                            : AppColors.darkSurfaceContainerHigh,
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkOutlineVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _titleController.text = role;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 5. Coaching Tone Selector
                  Text(
                    'COMPANION COACHING TONE',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _coachingTone = 'gentle');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _coachingTone == 'gentle'
                                  ? AppColors.primaryContainer.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppColors.darkSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _coachingTone == 'gentle'
                                    ? AppColors.primary
                                    : AppColors.darkOutlineVariant.withValues(
                                        alpha: 0.3,
                                      ),
                                width: _coachingTone == 'gentle' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '🌱',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gentle',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _coachingTone == 'gentle'
                                            ? AppColors.primary
                                            : AppColors.darkOnSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Patient, reflective, encouraging',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkOutline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _coachingTone = 'concise');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _coachingTone == 'concise'
                                  ? AppColors.primaryContainer.withValues(
                                      alpha: 0.3,
                                    )
                                  : AppColors.darkSurfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _coachingTone == 'concise'
                                    ? AppColors.primary
                                    : AppColors.darkOutlineVariant.withValues(
                                        alpha: 0.3,
                                      ),
                                width: _coachingTone == 'concise' ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      '⚡',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Concise',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _coachingTone == 'concise'
                                            ? AppColors.primary
                                            : AppColors.darkOnSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Direct, minimal, action-first',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.darkOutline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 6. Default Focus Session Duration
                  Text(
                    'DEFAULT FOCUS DURATION',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _focusOptions.map((mins) {
                      final isSelected = _focusDuration == mins;
                      return ChoiceChip(
                        label: Text('$mins min'),
                        selected: isSelected,
                        selectedColor: AppColors.primaryContainer.withValues(
                          alpha: 0.4,
                        ),
                        backgroundColor: AppColors.darkSurfaceContainerHigh,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkOnSurfaceVariant,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.darkOutlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            HapticFeedback.selectionClick();
                            setState(() => _focusDuration = mins);
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 7. Evening Reflection Time
                  Text(
                    'EVENING REFLECTION RITUAL',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: AppColors.darkOutline,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.darkOutlineVariant.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.nightlight_round,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _eveningTime,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkOnSurface,
                              ),
                            ),
                          ],
                        ),
                        TextButton.icon(
                          onPressed: _pickEveningTime,
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('Change Time'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 8. Save and Cancel Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      child: Text(
                        'Save Changes',
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.darkOutline,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
