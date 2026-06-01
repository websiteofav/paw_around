import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class VaccineDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final String? error;
  final VoidCallback onTap;
  final String? helperText;
  final bool visible;

  const VaccineDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.error,
    required this.onTap,
    this.helperText,
    this.visible = true,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Text(
            label,
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
          const SizedBox(width: 4),
          Text(
            '*',
            style: AppTextStyles.interRegularStyle400(
                fontSize: 14, fontColor: AppColors.grey1000),
          ),
        ]),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: smoothDecoration(
              cornerRadius: 14,
              color: AppColors.surface,
              side: BorderSide(
                color: error != null ? AppColors.error : AppColors.neutral300,
              ),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  selectedDate != null
                      ? _formatDate(selectedDate!)
                      : AppStrings.selectDate,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 16,
                    fontColor: selectedDate != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              const Icon(
                Icons.calendar_month,
                color: AppColors.secondaryCTA,
                size: 22,
              ),
            ]),
          ),
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
        if (helperText != null && error == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              helperText!,
              style: AppTextStyles.regularStyle400(
                  fontSize: 12, fontColor: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }
}
