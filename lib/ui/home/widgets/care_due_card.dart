import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';

/// A reusable card for displaying care items that are due or overdue.
/// Used for Grooming, Tick & Flea, and other care reminders.
class CareDueCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badgeText;
  final String actionText;
  final Color gradientStart;
  final Color gradientEnd;
  final Color badgeColor;
  final Color badgeTextColor;
  final bool isOverdue;

  const CareDueCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeText,
    required this.actionText,
    required this.gradientStart,
    required this.gradientEnd,
    required this.badgeColor,
    required this.badgeTextColor,
    this.isOverdue = false,
  });

  /// Factory constructor for Tick & Flea card
  factory CareDueCard.tickFlea({
    String? badgeText,
    required String subtitle,
    required String actionText,
    bool isOverdue = false,
  }) {
    return CareDueCard(
      icon: Icons.shield_outlined,
      title: 'Tick & Flea Prevention',
      subtitle: subtitle,
      badgeText: badgeText,
      actionText: actionText,
      gradientStart: AppColors.tickFleaGradientStart,
      gradientEnd: AppColors.tickFleaGradientEnd,
      badgeColor: AppColors.tickFleaBadge,
      badgeTextColor: AppColors.tickFleaBadgeText,
      isOverdue: isOverdue,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use urgent/warning colors when overdue for prominent badge
    final effectiveBadgeColor = isOverdue ? AppColors.urgentBadge : badgeColor;
    final effectiveBadgeTextColor =
        isOverdue ? AppColors.urgentBadgeText : badgeTextColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradientStart, gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: gradientStart.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
              // Frosted glass icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              // Badge - prominent yellow when overdue
              if (badgeText != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: effectiveBadgeColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTextStyles.semiBoldStyle600(
                        fontSize: 12, fontColor: effectiveBadgeTextColor),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          Text(
            title,
            style: AppTextStyles.boldStyle700(
                fontSize: 20, fontColor: AppColors.white),
          ),

          const SizedBox(height: 4),

          // Subtitle
          Text(
            subtitle,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.white.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 16),

          // Bottom row: Action text with chevron
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                actionText,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.white,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
