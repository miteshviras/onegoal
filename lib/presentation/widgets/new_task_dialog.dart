import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class NewTaskDialog extends ConsumerStatefulWidget {
  const NewTaskDialog({super.key});

  @override
  ConsumerState<NewTaskDialog> createState() => _NewTaskDialogState();
}

class _NewTaskDialogState extends ConsumerState<NewTaskDialog> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  late final TextEditingController _customDurationController;

  TimeOfDay _selectedTime = const TimeOfDay(hour: 16, minute: 0); // 04:00 PM
  int _duration = 25; // in minutes (1 to 240)
  bool _isCustomMode = false;
  String? _durationError;

  static const List<int> _presetDurations = [15, 25, 45, 60, 90, 120, 180, 240];

  @override
  void initState() {
    super.initState();
    _customDurationController = TextEditingController(text: '$_duration');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (mins == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    }
    return '$hours hr${hours > 1 ? 's' : ''} $mins min';
  }

  String _presetLabel(int minutes) {
    switch (minutes) {
      case 15:
        return '15m';
      case 25:
        return '25m';
      case 45:
        return '45m';
      case 60:
        return '1 hr';
      case 90:
        return '1.5 hrs';
      case 120:
        return '2 hrs';
      case 180:
        return '3 hrs';
      case 240:
        return '4 hrs';
      default:
        return '$minutes m';
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime() async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.darkSurfaceContainer,
              onSurface: AppColors.darkOnSurface,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _selectPreset(int minutes) {
    HapticFeedback.selectionClick();
    setState(() {
      _duration = minutes;
      _isCustomMode = false;
      _durationError = null;
      _customDurationController.text = '$minutes';
    });
  }

  void _updateCustomDuration(int value) {
    final clamped = value.clamp(1, 240);
    setState(() {
      _duration = clamped;
      _durationError = null;
      _customDurationController.text = '$clamped';
    });
  }

  void _onCustomInputChanged(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _durationError = 'Enter 1 - 240 mins';
      });
      return;
    }
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 1) {
      setState(() {
        _durationError = 'Minimum is 1 minute';
      });
    } else if (parsed > 240) {
      setState(() {
        _durationError = 'Maximum is 4 hours (240 min)';
      });
    } else {
      setState(() {
        _duration = parsed;
        _durationError = null;
      });
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an action title'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_duration < 1 || _duration > 240) {
      setState(() {
        _durationError = 'Duration must be between 1 and 240 min (max 4 hrs)';
      });
      return;
    }

    ref.read(tasksNotifierProvider.notifier).addTask(
          title: title,
          subtitle: _subtitleController.text.trim(),
          scheduledTime: _formatTimeOfDay(_selectedTime),
          durationMinutes: _duration,
        );

    HapticFeedback.mediumImpact();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurfaceContainer,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '+ Add Time Block',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.darkOutline),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Action Title
              const Text(
                'Action Title',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkOnSurface,
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(_titleController, 'e.g., Draft design tokens'),
              const SizedBox(height: 12),

              // Context / Subtitle
              const Text(
                'Context / Subtitle (Optional)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkOnSurface,
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(
                _subtitleController,
                'e.g., Manrope typography & hex palette',
              ),
              const SizedBox(height: 16),

              // Time Picker
              const Text(
                'Scheduled Time',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkOnSurface,
                ),
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
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
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _formatTimeOfDay(_selectedTime),
                            style: const TextStyle(
                              color: AppColors.darkOnSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Duration Header with active pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Block Duration',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkOnSurface,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      _formatDuration(_duration),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Preset Duration Chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._presetDurations.map((m) {
                    final isSelected = !_isCustomMode && _duration == m;
                    return ChoiceChip(
                      label: Text(_presetLabel(m)),
                      selected: isSelected,
                      onSelected: (_) => _selectPreset(m),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.darkSurfaceContainerLow,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : AppColors.darkOnSurface,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                      ),
                    );
                  }),
                  ChoiceChip(
                    label: const Text('Custom min'),
                    selected: _isCustomMode || !_presetDurations.contains(_duration),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _isCustomMode = true;
                        _customDurationController.text = '$_duration';
                      });
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.darkSurfaceContainerLow,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          (_isCustomMode || !_presetDurations.contains(_duration))
                              ? FontWeight.bold
                              : FontWeight.normal,
                      color: (_isCustomMode || !_presetDurations.contains(_duration))
                          ? Colors.white
                          : AppColors.darkOnSurface,
                    ),
                    side: BorderSide(
                      color: (_isCustomMode || !_presetDurations.contains(_duration))
                          ? AppColors.primary
                          : AppColors.darkOutlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),

              // Custom Duration Input Panel (always visible if Custom is active or duration is non-preset)
              if (_isCustomMode || !_presetDurations.contains(_duration)) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _durationError != null
                          ? AppColors.error
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _customDurationController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkOnSurface,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                suffixText: 'minutes',
                                suffixStyle: TextStyle(
                                  color: AppColors.darkOutline,
                                  fontSize: 13,
                                ),
                                hintText: '1 - 240',
                                hintStyle: TextStyle(color: AppColors.darkOutline),
                                border: InputBorder.none,
                              ),
                              onChanged: _onCustomInputChanged,
                            ),
                          ),
                          // Quick Stepper Buttons
                          _buildStepButton('-15', () => _updateCustomDuration(_duration - 15)),
                          const SizedBox(width: 4),
                          _buildStepButton('-5', () => _updateCustomDuration(_duration - 5)),
                          const SizedBox(width: 4),
                          _buildStepButton('+5', () => _updateCustomDuration(_duration + 5)),
                          const SizedBox(width: 4),
                          _buildStepButton('+15', () => _updateCustomDuration(_duration + 15)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Slider for smooth selection up to 240 min (4 hrs)
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.darkSurfaceContainerHigh,
                          thumbColor: AppColors.primary,
                          trackHeight: 3,
                          thumbShape:
                              const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape:
                              const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: _duration.clamp(5, 240).toDouble(),
                          min: 5,
                          max: 240,
                          divisions: 47, // 5 min increments from 5 to 240
                          onChanged: (val) {
                            _updateCustomDuration(val.round());
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '5 min',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.darkOutline,
                            ),
                          ),
                          Text(
                            '2 hrs (120m)',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.darkOutline,
                            ),
                          ),
                          Text(
                            '4 hrs (240m)',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.darkOutline,
                            ),
                          ),
                        ],
                      ),
                      if (_durationError != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          _durationError!,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 22),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    'Schedule ${_formatDuration(_duration)} Block',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: AppColors.darkOutlineVariant.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.darkOnSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: AppColors.darkOnSurface),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: AppColors.darkOutline),
        ),
      ),
    );
  }
}
