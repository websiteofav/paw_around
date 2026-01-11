import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class ActionInfoCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onLearnMoreTap;

  const ActionInfoCard({
    super.key,
    required this.title,
    required this.description,
    this.icon,
    this.iconColor,
    this.onLearnMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with icon
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: effectiveIconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    icon,
                    color: effectiveIconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.semiBoldStyle600(fontSize: 17, fontColor: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            description,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          if (onLearnMoreTap != null) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onLearnMoreTap,
              child: Row(
                children: [
                  Text(
                    AppStrings.learnMore,
                    style: AppTextStyles.semiBoldStyle600(fontSize: 14, fontColor: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
