import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/utils/date_utils.dart';

class CareHistoryCard extends StatelessWidget {
  final DateTime? lastDate;
  final DateTime? nextDueDate;
  final String? frequency;
  final ActionType actionType;

  const CareHistoryCard({
    super.key,
    this.lastDate,
    this.nextDueDate,
    this.frequency,
    required this.actionType,
  });

  String _formatDate(DateTime date) {
    return AppDateUtils.formatMonthDayYear(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.history,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  AppStrings.careHistory,
                  style: AppTextStyles.semiBoldStyle600(
                      fontSize: 17, fontColor: AppColors.textPrimary),
                ),
              ),
              if (frequency != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    frequency!,
                    style: AppTextStyles.mediumStyle500(
                        fontSize: 12, fontColor: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Timeline
          _buildTimelineItem(
            icon: Icons.check_circle,
            iconColor: AppColors.success,
            label: AppStrings.lastCompleted,
            value:
                lastDate != null ? _formatDate(lastDate!) : AppStrings.notSet,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.arrow_forward,
            iconColor: AppColors.primary,
            label: AppStrings.nextDue,
            value: nextDueDate != null
                ? _formatDate(nextDueDate!)
                : AppStrings.notSet,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 14),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.regularStyle400(
                      fontSize: 13, fontColor: AppColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.semiBoldStyle600(
                      fontSize: 15, fontColor: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
