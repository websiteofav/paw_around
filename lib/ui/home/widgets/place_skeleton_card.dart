import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';

/// Skeleton card for place list items in map screen
class PlaceSkeletonCard extends StatelessWidget {
  const PlaceSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: smoothDecoration(
        cornerRadius: 16,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon skeleton
          Container(
            width: 56,
            height: 56,
            decoration: smoothDecoration(
              cornerRadius: 14,
              color: AppColors.border,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title skeleton
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.border,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle skeleton
                Container(
                  height: 12,
                  width: 150,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.border,
                  ),
                ),
                const SizedBox(height: 8),
                // Rating skeleton
                Container(
                  height: 12,
                  width: 80,
                  decoration: smoothDecoration(
                    cornerRadius: 4,
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Directions button skeleton
          Container(
            width: 40,
            height: 40,
            decoration: smoothDecoration(
              cornerRadius: 12,
              color: AppColors.border,
            ),
          ),
        ],
      ),
    );
  }
}
