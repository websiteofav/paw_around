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
        children: [
          // Left: Paw icon in circular background
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.iconBgLight,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.pets,
              color: AppColors.primary,
              size: 22,
            ),
          ),

          // Center: Title and subtitle
          Expanded(
            child: Column(
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
          ),

          // Right: Notification bell
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
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
