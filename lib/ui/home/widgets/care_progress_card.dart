import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class CareProgressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final int daysLeft;
  final int totalDays;

  const CareProgressCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.daysLeft,
    required this.totalDays,
  });

  bool get isOverdue {
    return daysLeft < 0;
  }

  @override
  Widget build(BuildContext context) {
    // When overdue, show full progress bar; otherwise calculate normally
    final progress = isOverdue ? 1.0 : (totalDays > 0 ? (totalDays - daysLeft) / totalDays : 0.0);

    // Badge text: "Overdue by X days" or "X days left"
    final badgeText = isOverdue ? 'Overdue by ${daysLeft.abs()} days' : '${daysLeft.abs()} ${AppStrings.daysLeft}';

    // Colors based on overdue state
    final badgeBgColor = isOverdue ? AppColors.error.withValues(alpha: 0.15) : AppColors.progressBarBg;
    final badgeTextColor = isOverdue ? AppColors.error : AppColors.textSecondary;
    final progressBarColor = isOverdue ? AppColors.error : AppColors.progressBarFill;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Icon and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.cardBlueIconBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.cardBlueIcon,
                  size: 24,
                ),
              ),
              // Days left badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: AppTextStyles.mediumStyle500(fontSize: 12, fontColor: badgeTextColor),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: AppTextStyles.boldStyle700(fontSize: 18, fontColor: AppColors.textPrimary),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle ?? AppStrings.protectionActive,
            style: AppTextStyles.regularStyle400(fontSize: 14, fontColor: AppColors.textSecondary),
          ),

          const SizedBox(height: 16),

          // Progress bar and chevron
          Row(
            children: [
              // Progress bar
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.progressBarBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: progressBarColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
