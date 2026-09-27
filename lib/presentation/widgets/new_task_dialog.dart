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
  String _time = '04:00 PM';
  int _duration = 25;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    ref.read(tasksNotifierProvider.notifier).addTask(
          title: title,
          subtitle: _subtitleController.text.trim(),
          scheduledTime: _time,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text(
                  '+ Add Time Block',
                  style: TextStyle(
                    fontSize: 20,
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
            const Text(
              'Context / Subtitle',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkOnSurface,
              ),
            ),
            const SizedBox(height: 6),
            _buildTextField(
                _subtitleController, 'e.g., Manrope typography & hex palette'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Time',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkOnSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButton<String>(
                          value: _time,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.darkSurfaceContainer,
                          style: const TextStyle(
                            color: AppColors.darkOnSurface,
                            fontSize: 13,
                          ),
                          items: [
                            '08:00 AM',
                            '09:00 AM',
                            '10:30 AM',
                            '01:30 PM',
                            '03:00 PM',
                            '04:00 PM',
                            '05:30 PM',
                          ].map((t) {
                            return DropdownMenuItem(value: t, child: Text(t));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _time = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkOnSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainerLow,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkOutlineVariant
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: DropdownButton<int>(
                          value: _duration,
                          isExpanded: true,
                          underline: const SizedBox(),
                          dropdownColor: AppColors.darkSurfaceContainer,
                          style: const TextStyle(
                            color: AppColors.darkOnSurface,
                            fontSize: 13,
                          ),
                          items: [15, 25, 30, 45, 60].map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text('$d min'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _duration = val);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                child: const Text(
                  'Schedule Block',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
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
