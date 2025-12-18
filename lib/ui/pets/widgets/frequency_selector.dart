import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';

class FrequencySelector extends StatelessWidget {
  final String title;
  final CareFrequency selectedFrequency;
  final List<CareFrequency> options;
  final ValueChanged<CareFrequency> onChanged;

  const FrequencySelector({
    super.key,
    required this.title,
    required this.selectedFrequency,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((frequency) => _buildOption(frequency)),
        ],
      ),
    );
  }

  Widget _buildOption(CareFrequency frequency) {
    final isSelected = frequency == selectedFrequency;

    return GestureDetector(
      onTap: () => onChanged(frequency),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.iconBgLight : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getDisplayName(frequency),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: AppColors.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  String _getDisplayName(CareFrequency frequency) {
    switch (frequency) {
      case CareFrequency.none:
        return AppStrings.noReminder;
      case CareFrequency.weekly:
        return AppStrings.everyWeek;
      case CareFrequency.monthly:
        return AppStrings.everyMonth;
      case CareFrequency.quarterly:
        return AppStrings.every3Months;
    }
  }
}
