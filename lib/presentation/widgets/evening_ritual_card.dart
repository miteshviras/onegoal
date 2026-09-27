import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';

class EveningRitualCard extends ConsumerStatefulWidget {
  const EveningRitualCard({super.key});

  @override
  ConsumerState<EveningRitualCard> createState() => _EveningRitualCardState();
}

class _EveningRitualCardState extends ConsumerState<EveningRitualCard> {
  String _selectedMood = 'great';
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitted = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    ref.read(progressNotifierProvider.notifier).submitReflection(
          mood: _selectedMood,
          note: _noteController.text.trim(),
        );
    setState(() {
      _isSubmitted = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.darkSurfaceContainerHigh,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.spa, color: AppColors.successEmerald, size: 20),
            SizedBox(width: 10),
            Text(
              'Evening ritual complete. Rest well tonight.',
              style: TextStyle(color: AppColors.darkOnSurface),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.bedtime,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Evening Check-in',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkOnSurface,
                            ),
                      ),
                      const Text(
                        '2-minute reset ritual',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.darkOutline,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
                decoration: BoxDecoration(
                  color: _isSubmitted
                      ? AppColors.successEmerald.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isSubmitted ? 'Completed' : 'Active',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isSubmitted
                        ? AppColors.successEmerald
                        : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'How did today feel?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkOnSurface,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildMoodButton('great', '😊', 'Great'),
              const SizedBox(width: 8),
              _buildMoodButton('balanced', '😐', 'Balanced'),
              const SizedBox(width: 8),
              _buildMoodButton('tough', '😞', 'Tough'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: const [
              Text(
                'What unblocked you today?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkOnSurface,
                ),
              ),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.darkOutline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkOutlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: TextField(
              controller: _noteController,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.darkOnSurface,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(12),
                border: InputBorder.none,
                hintText:
                    'e.g., Turning off instant notifications for two 45-minute sprint blocks...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: AppColors.darkOutline,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Text(
                'Logged privately to your story',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.darkOutline,
                ),
              ),
              FilledButton(
                onPressed: _isSubmitted ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  _isSubmitted ? 'Ritual Done' : 'Complete Ritual',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String moodKey, String emoji, String label) {
    final isSelected = _selectedMood == moodKey;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedMood = moodKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.3)
                : AppColors.darkSurfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.darkOutlineVariant.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 24,
                  transform: isSelected
                      ? (Matrix4.identity()..scale(1.15))
                      : Matrix4.identity(),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.darkOnSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
