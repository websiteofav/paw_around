import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';

class CareSummarySection extends StatelessWidget {
  final int activeTasks;
  final int urgentCount;
  final int scheduledCount;

  const CareSummarySection({
    super.key,
    required this.activeTasks,
    required this.urgentCount,
    required this.scheduledCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            AppColors.summaryGradientStart,
            AppColors.summaryGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.careSummary,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 12),

          // Stats grid
          Row(
            children: [
              // Active Tasks
              Expanded(
                child: _buildStatItem(
                  value: activeTasks.toString(),
                  label: AppStrings.activeTasks,
                  color: AppColors.statPurple,
                ),
              ),
              // Urgent
              Expanded(
                child: _buildStatItem(
                  value: urgentCount.toString(),
                  label: AppStrings.urgent,
                  color: AppColors.statPink,
                ),
              ),
              // Scheduled
              Expanded(
                child: _buildStatItem(
                  value: scheduledCount.toString(),
                  label: AppStrings.scheduled,
                  color: AppColors.statEmerald,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
