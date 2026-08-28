import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';

class GroomingTypeSelector extends StatelessWidget {
  final List<String> selectedTypes;
  final ValueChanged<List<String>> onChanged;
  final String? error;

  const GroomingTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onChanged,
    this.error,
  });

  void _toggle(String type) {
    final updated = List<String>.from(selectedTypes);
    if (updated.contains(type)) {
      updated.remove(type);
    } else {
      updated.add(type);
    }
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            AppStrings.groomingType,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.requiredIndicator),
          ),
        ]),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: CareSettingsModel.allGroomingTypes
              .map((type) => _GroomingChip(
                    label: type,
                    isSelected: selectedTypes.contains(type),
                    onTap: () => _toggle(type),
                  ))
              .toList(),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              error!,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.error),
            ),
          ),
      ],
    );
  }
}

class _GroomingChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroomingChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: smoothDecoration(
          cornerRadius: 999,
          color: isSelected ? AppColors.secondaryCTA : AppColors.background3,
        ),
        child: Text(
          label,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 16,
            fontColor: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
