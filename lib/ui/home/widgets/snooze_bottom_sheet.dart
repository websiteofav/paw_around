import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

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
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.iconBgLight,
              borderRadius: BorderRadius.circular(32),
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
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
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
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
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
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
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
