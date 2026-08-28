import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/action_timeline_entry.dart';
import 'package:paw_around/utils/date_utils.dart';
import 'package:paw_around/utils/utils.dart';

class ActionCardTimeline extends StatelessWidget {
  final PetModel pet;
  final ActionType? filterByActionType;
  final String? filterByVaccineName;

  const ActionCardTimeline({
    super.key,
    required this.pet,
    this.filterByActionType,
    this.filterByVaccineName,
  });

  String _formatDate(DateTime date) {
    return AppDateUtils.formatDateLong(date);
  }

  @override
  Widget build(BuildContext context) {
    final groupedEntries = PetTimelineUtils.buildGroupedTimeline(
      pet: pet,
      filterByActionType: filterByActionType,
      filterByVaccineName: filterByVaccineName,
    );

    if (groupedEntries.isEmpty) {
      return Container(
        width: double.infinity,
        padding: AppEdgeInsets.cardPadding,
        decoration: smoothDecoration(
          cornerRadius: AppConstants.radiusLG,
          color: AppColors.surface,
          shadows: [
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
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: smoothDecoration(
                    cornerRadius: 16,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                  child: const Icon(
                    Icons.timeline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                AppSpacing.horizontal14,
                Expanded(
                  child: Text(
                    AppStrings.actionTimeline,
                    style: AppTextStyles.semiBoldStyle600(
                      fontSize: 17,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.vertical20,
            Center(
              child: Text(
                AppStrings.noTimelineEntries,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: AppEdgeInsets.cardPadding,
      decoration: smoothDecoration(
        cornerRadius: 20,
        color: AppColors.surface,
        shadows: [
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
                decoration: smoothDecoration(
                  cornerRadius: AppConstants.radiusMD,
                  color: AppColors.primary.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.timeline,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              AppSpacing.horizontal14,
              Expanded(
                child: Text(
                  AppStrings.actionTimeline,
                  style: AppTextStyles.semiBoldStyle600(
                    fontSize: 17,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vertical20,

          // Grouped Timeline Entries
          ...groupedEntries.entries.map((entry) {
            final actionType = entry.key;
            final entries = entry.value;
            final isLastGroup = entry == groupedEntries.entries.last;

            return _buildCareTypeSection(
              actionType: actionType,
              entries: entries,
              isLast: isLastGroup,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCareTypeSection({
    required ActionType actionType,
    required List<ActionTimelineEntry> entries,
    required bool isLast,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Icon(
              actionType.icon,
              size: 18,
              color: AppColors.textSecondary,
            ),
            AppSpacing.horizontal8,
            Text(
              actionType.title,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        AppSpacing.vertical12,

        // Timeline entries for this care type
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLastEntry = index == entries.length - 1;

          return _buildTimelineItem(
            actionName: item.actionName,
            date: item.date,
            status: item.status,
            isLast: isLastEntry && isLast,
          );
        }),

        // Spacing between sections
        if (!isLast) AppSpacing.vertical24,
      ],
    );
  }

  Widget _buildTimelineItem({
    required String actionName,
    DateTime? date,
    required TimelineEntryStatus status,
    required bool isLast,
  }) {
    final isCompleted = status == TimelineEntryStatus.completed;
    final icon = isCompleted ? Icons.check_circle : Icons.cancel_outlined;
    final iconColor = isCompleted ? AppColors.success : AppColors.textSecondary;
    final dateText = date != null ? _formatDate(date) : null;
    final statusText = isCompleted ? AppStrings.done : AppStrings.skipped;

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
        AppSpacing.horizontal14,
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : AppConstants.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$actionName — $statusText',
                  style: AppTextStyles.semiBoldStyle600(
                    fontSize: 15,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
                if (dateText != null) ...[
                  AppSpacing.vertical4,
                  Text(
                    dateText,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 13,
                      fontColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
