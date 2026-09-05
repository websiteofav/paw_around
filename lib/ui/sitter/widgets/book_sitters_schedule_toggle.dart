import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Schedule / Multi-day segmented toggle at the top of the Book Sitters
/// screen. Multi-day has no distinct content defined yet — this is
/// visual/stateful only for now.
class BookSittersScheduleToggle extends StatelessWidget {
  final bool isScheduleSelected;
  final ValueChanged<bool> onChanged;

  const BookSittersScheduleToggle({
    super.key,
    required this.isScheduleSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: smoothDecoration(
        cornerRadius: 24,
        color: AppColors.quickActionVaccines,
      ),
      child: Row(
        spacing: 4,
        children: [
          Expanded(
            child: _ToggleSegment(
              label: AppStrings.scheduleTab,
              isSelected: isScheduleSelected,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _ToggleSegment(
              label: AppStrings.multiDayTab,
              isSelected: !isScheduleSelected,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleSegment extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleSegment({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: smoothDecoration(
          cornerRadius: 18,
          color: isSelected ? AppColors.grey1000 : AppColors.white,
          shadows: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.1020),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.0902),
                    offset: const Offset(0, 10),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.0510),
                    offset: const Offset(0, 23),
                    blurRadius: 14,
                  ),
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0.0118),
                    offset: const Offset(0, 41),
                    blurRadius: 16,
                  ),
                  BoxShadow(
                    color: AppColors.shadowOverlay.withValues(alpha: 0),
                    offset: const Offset(0, 63),
                    blurRadius: 18,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 14,
            fontColor: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
