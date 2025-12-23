import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class GroomingDueCard extends StatelessWidget {
  final String? badgeText;
  final VoidCallback onTap;

  const GroomingDueCard({
    super.key,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.groomingGradientStart,
              AppColors.groomingGradientEnd,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.groomingGradientStart.withValues(alpha: 0.3),
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
                  child: const Icon(
                    Icons.content_cut,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.groomingBadge,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badgeText ?? AppStrings.thisWeek,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.groomingBadgeText,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Title
            const Text(
              AppStrings.groomingSession,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),

            const SizedBox(height: 4),

            // Subtitle
            Text(
              '${AppStrings.timeForFreshTrim} ✨',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: 16),

            // Bottom row: Action text with chevron
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.scheduleAppointment,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.9),
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
      ),
    );
  }
}
