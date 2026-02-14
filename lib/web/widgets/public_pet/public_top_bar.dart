import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Minimal top bar for public pet profile: logo + "Paw Around".
class PublicPetTopBar extends StatelessWidget {
  const PublicPetTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: AppBorderRadius.full,
              ),
              child: const Icon(Icons.pets, color: AppColors.white, size: 22),
            ),
            AppSpacing.horizontal12,
            Text(
              AppStrings.publicProfileAppTitle,
              style: AppTextStyles.boldStyle700(
                fontSize: 20,
                fontColor: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
