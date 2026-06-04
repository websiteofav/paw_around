import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class PetOverviewActivitySection extends StatelessWidget {
  const PetOverviewActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.activityHistory,
              style: AppTextStyles.interBoldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(AppIcons.petNoActivityIcon,
                  height: 168, width: 348, fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(AppStrings.noActivityYet,
                  style: AppTextStyles.interBoldStyle700(
                      fontSize: 14, fontColor: AppColors.grey600)),
              const SizedBox(height: 4),
              Text(AppStrings.startLoggingCare,
                  style: AppTextStyles.interMediumStyle500(
                      fontSize: 14, fontColor: AppColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }
}
