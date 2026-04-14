import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

const List<String> kPetPersonalityOptions = [
  'Leash trained',
  'Friendly with cats',
  'Active',
  'Moody',
  'Tries to eat things',
  'Loves cuddles',
  'Food obsessed',
  'Shy around strangers',
  'Protective',
  'Attention Seeker',
  'Loves Walks',
  'Drama queen',
  'Little troublemaker',
  'Calm & Relaxed',
  'Curious explorer',
  'Nap lover',
  'Ball is life',
];

class PetPersonalitySelector extends StatelessWidget {
  final List<String> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  const PetPersonalitySelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...options.map((tag) {
          final isSelected = selected.contains(tag);
          return GestureDetector(
            onTap: () {
              final updated = List<String>.from(selected);
              isSelected ? updated.remove(tag) : updated.add(tag);
              onChanged(updated);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isSelected ? AppColors.primary : AppColors.neutral300),
              ),
              child: Text(
                tag,
                style: AppTextStyles.regularStyle400(
                  fontSize: 13,
                  fontColor: isSelected ? AppColors.secondaryCTA : AppColors.textPrimary,
                ),
              ),
            ),
          );
        }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: Text(
            AppStrings.addYourOwn,
            style: AppTextStyles.regularStyle400(fontSize: 13, fontColor: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
