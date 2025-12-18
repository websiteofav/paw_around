import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class ActionSummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? petImageUrl;
  final bool isOverdue;

  const ActionSummaryCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.petImageUrl,
    this.isOverdue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pet avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.iconBgLight,
              borderRadius: BorderRadius.circular(28),
            ),
            child: petImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.network(
                      petImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.pets,
                          color: AppColors.primary,
                          size: 28,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.pets,
                    color: AppColors.primary,
                    size: 28,
                  ),
          ),
          const SizedBox(width: 16),
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Status chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isOverdue ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOverdue ? AppColors.error : AppColors.primary,
                width: 1,
              ),
            ),
            child: Text(
              isOverdue ? AppStrings.overdue : AppStrings.dueSoon,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isOverdue ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
