import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class SnoozeBottomSheet extends StatelessWidget {
  final VoidCallback onSnooze3Days;
  final VoidCallback onSnooze7Days;

  const SnoozeBottomSheet({
    super.key,
    required this.onSnooze3Days,
    required this.onSnooze7Days,
  });

  static Future<int?> show(BuildContext context) {
    return showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SnoozeBottomSheet(
        onSnooze3Days: () => Navigator.of(context).pop(3),
        onSnooze7Days: () => Navigator.of(context).pop(7),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(24),
        color: AppColors.surface,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: smoothDecoration(
              cornerRadius: 2,
              color: AppColors.border,
            ),
          ),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: smoothDecoration(
              cornerRadius: 32,
              color: AppColors.iconBgLight,
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            AppStrings.snoozeAction,
            style: AppTextStyles.semiBoldStyle600(fontSize: 20, fontColor: AppColors.textPrimary),
          ),
          const SizedBox(height: 24),
          // Snooze options
          _buildSnoozeOption(
            title: AppStrings.snoozeFor3Days,
            onTap: onSnooze3Days,
          ),
          const SizedBox(height: 8),
          _buildSnoozeOption(
            title: AppStrings.snoozeFor7Days,
            onTap: onSnooze7Days,
          ),
          const SizedBox(height: 16),
          // Cancel
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.mediumStyle500(fontSize: 16, fontColor: AppColors.textSecondary),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSnoozeOption({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: smoothDecoration(
          cornerRadius: 14,
          color: AppColors.background,
          side: const BorderSide(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.regularStyle400(fontSize: 16, fontColor: AppColors.textPrimary),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
