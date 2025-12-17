import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class HomeAppBar extends StatelessWidget {
  final String? petName;
  final String? petAge;
  final VoidCallback? onNotificationTap;

  const HomeAppBar({
    super.key,
    this.petName,
    this.petAge,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Spacer(),
          // Center: Title and subtitle
          Column(
            children: [
              const Text(
                AppStrings.homeTab,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (petName != null && petAge != null)
                Text(
                  '$petName · $petAge',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Right: Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
