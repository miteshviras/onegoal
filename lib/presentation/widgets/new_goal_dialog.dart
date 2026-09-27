import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class NewGoalDialog extends ConsumerStatefulWidget {
  const NewGoalDialog({super.key});

  @override
  ConsumerState<NewGoalDialog> createState() => _NewGoalDialogState();
}

class _NewGoalDialogState extends ConsumerState<NewGoalDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _affirmationController = TextEditingController();
  String _category = 'Career & Craft';
  int _dueInDays = 30;
  final List<TextEditingController> _milestoneControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final _categories = [
    'Career & Craft',
    'Health & Energy',
    'Finance',
    'Mindset',
    'Personal Growth',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _affirmationController.dispose();
    for (final c in _milestoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMilestoneField() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final milestones = _milestoneControllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    ref.read(goalsNotifierProvider.notifier).createGoal(
          title: title,
          description: _descController.text.trim(),
          category: _category,
          dueInDays: _dueInDays,
          affirmation: _affirmationController.text.trim().isEmpty
              ? 'You are becoming someone who finishes what they start.'
              : _affirmationController.text.trim(),
          milestoneTitles: milestones.isEmpty
              ? ['Define core scope & outline', 'Execute initial sprint prototype']
              : milestones,
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '+ New Horizon',
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
            const SizedBox(height: 6),
            const Text(
              'Limit to 3 active quarterly goals. Quality over quantity.',
              style: TextStyle(fontSize: 12, color: AppColors.darkOutline),
            ),
            const SizedBox(height: 16),
            _buildLabel('Goal Title'),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g. Master Design Systems in Flutter',
            ),
            const SizedBox(height: 14),
            _buildLabel('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _category = cat);
                  },
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.darkSurfaceContainerLow,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.darkOnSurfaceVariant,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            _buildLabel('Target Horizon (Days)'),
            Slider(
              value: _dueInDays.toDouble(),
              min: 7,
              max: 90,
              divisions: 12,
              activeColor: AppColors.primary,
              inactiveColor: AppColors.darkSurfaceContainerHighest,
              label: '$_dueInDays days',
              onChanged: (val) => setState(() => _dueInDays = val.toInt()),
            ),
            Center(
              child: Text(
                'Due in $_dueInDays days',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildLabel('Identity Affirmation (Why this matters)'),
            _buildTextField(
              controller: _affirmationController,
              hint: 'e.g. “I build high-craft products consistently.”',
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Milestones'),
                TextButton.icon(
                  onPressed: _addMilestoneField,
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Add',
                    style: TextStyle(color: AppColors.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
            ..._milestoneControllers.asMap().entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTextField(
                  controller: entry.value,
                  hint: 'Milestone ${entry.key + 1}',
                ),
              );
            }),
            const SizedBox(height: 18),
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
                  'Create Goal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.darkOnSurface,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
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
