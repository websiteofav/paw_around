import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/action_timeline_entry.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/utils/date_utils.dart' as app_date_utils;
import 'package:paw_around/utils/utils.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PetOverviewActivitySection extends StatefulWidget {
  final PetModel pet;

  const PetOverviewActivitySection({super.key, required this.pet});

  @override
  State<PetOverviewActivitySection> createState() =>
      _PetOverviewActivitySectionState();
}

class _PetOverviewActivitySectionState
    extends State<PetOverviewActivitySection> {
  static const int _initialVisibleCount = 3;
  static const int _loadMoreCount = 3;

  int _visibleCount = _initialVisibleCount;

  List<ActionTimelineEntry> get _entries {
    final grouped = PetTimelineUtils.buildGroupedTimeline(pet: widget.pet);
    final entries = grouped.values.expand((entries) => entries).toList();
    entries.sort((a, b) {
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });
    return entries;
  }

  void _loadMore() {
    setState(() => _visibleCount += _loadMoreCount);
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final visibleEntries = entries.take(_visibleCount).toList();
    final canLoadMore = visibleEntries.length < entries.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.activityHistory,
              style: AppTextStyles.interBoldStyle700(
                  fontSize: 18, fontColor: AppColors.grey1100)),
          const SizedBox(height: 20),
          if (entries.isEmpty)
            _EmptyActivityState()
          else ...[
            for (final entry in visibleEntries) _ActivityHistoryTile(entry),
            if (canLoadMore) ...[
              const SizedBox(height: 12),
              Center(
                child: ScaleButton(
                  onPressed: _loadMore,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background3,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Text(
                      'Load more',
                      style: AppTextStyles.interBoldStyle700(
                        fontSize: 14,
                        fontColor: AppColors.secondaryCTA,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _ActivityHistoryTile extends StatelessWidget {
  final ActionTimelineEntry entry;

  const _ActivityHistoryTile(this.entry);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (entry.date != null) ...[
                  Text(
                    _formatDate(entry.date!),
                    style: AppTextStyles.interBoldStyle700(
                      fontSize: 12,
                      fontColor: AppColors.grey1100,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  _title,
                  style: AppTextStyles.interRegularStyle400(
                    fontSize: 16,
                    fontColor: AppColors.grey1100,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.grey1000,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right,
              color: AppColors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  String get _title {
    if (entry.status == TimelineEntryStatus.skipped) {
      return '${entry.actionName} skipped';
    }
    switch (entry.actionType) {
      case ActionType.vaccine:
        return '${entry.actionName} Vaccine done';
      case ActionType.grooming:
        return entry.actionName;
      case ActionType.tickFlea:
        return '${entry.actionName} done';
    }
  }

  String _formatDate(DateTime date) {
    final month = app_date_utils.AppDateUtils.getMonthAbbreviation(date.month);
    return '${date.day} $month ${date.year}';
  }
}

class _EmptyActivityState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(
          AppIcons.petNoActivityIcon,
          height: 168,
          width: 348,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 12),
        Text(AppStrings.noActivityYet,
            style: AppTextStyles.interBoldStyle700(
                fontSize: 14, fontColor: AppColors.grey600)),
        const SizedBox(height: 4),
        Text(AppStrings.startLoggingCare,
            style: AppTextStyles.interMediumStyle500(
                fontSize: 14, fontColor: AppColors.grey600)),
      ],
    );
  }
}
