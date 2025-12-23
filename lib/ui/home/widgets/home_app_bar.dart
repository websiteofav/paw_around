import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String? petName;
  final String? petAge;
  final String? petImageUrl;
  final VoidCallback? onNotificationTap;

  const HomeAppBar({
    super.key,
    this.petName,
    this.petAge,
    this.petImageUrl,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Pet avatar with gradient background
          Container(
            width: 48,
            height: 48,
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
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: petImageUrl != null && petImageUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      petImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPawIcon(),
                    ),
                  )
                : _buildPawIcon(),
          ),

          const SizedBox(width: 12),

          // Center-left: Pet name and age
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  petName ?? 'Your Pet',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (petAge != null)
                  Text(
                    petAge!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          // Right: Notification bell in gray circle
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.progressBarBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPawIcon() {
    return const Center(
      child: Text(
        '🐾',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
