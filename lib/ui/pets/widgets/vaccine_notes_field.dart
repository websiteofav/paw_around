import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class VaccineNotesField extends StatelessWidget {
  final TextEditingController controller;
  const VaccineNotesField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.notes,
          style: AppTextStyles.interRegularStyle400(
              fontSize: 14, fontColor: AppColors.grey1000),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.neutral300),
          ),
          child: TextField(
            controller: controller,
            maxLines: 4,
            style: AppTextStyles.regularStyle400(
                fontSize: 16, fontColor: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: AppStrings.optionalNotesHint,
              hintStyle: AppTextStyles.regularStyle400(
                  fontSize: 16, fontColor: AppColors.textSecondary),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
