import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';

class FrequencySelector extends StatelessWidget {
  final String title;
  final CareFrequency selectedFrequency;
  final List<CareFrequency> options;
  final ValueChanged<CareFrequency> onChanged;
  final String? subtitle;

  const FrequencySelector({
    super.key,
    required this.title,
    required this.selectedFrequency,
    required this.options,
    required this.onChanged,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 8),
        ...options.map((frequency) => _buildOption(frequency)),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Row(
            spacing: 2,
            children: [
              Image.asset(AppIcons.informationIcon, height: 20, width: 20),
              Text(
                subtitle!,
                style: AppTextStyles.interMediumStyle500(
                    fontSize: 14, fontColor: AppColors.grey700),
              ),
            ],
          ),
        ],
      ],
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
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getDisplayName(frequency),
              style: isSelected
                  ? AppTextStyles.mediumStyle500(
                      fontSize: 16, fontColor: AppColors.neutral700)
                  : AppTextStyles.regularStyle400(
                      fontSize: 16, fontColor: AppColors.neutral300),
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
