import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/date_utils.dart';

/// "Select your preferred day" row on the Book Sitters screen — the next 7
/// days starting today.
class BookSittersDaySelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const BookSittersDaySelector({
    super.key,
    required this.selectedIndex,
    required this.onSelect,
  });

  static const int _dayCount = 7;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectYourPreferredDay,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _dayCount,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final date = today.add(Duration(days: index));
              final isSelected = index == selectedIndex;
              return GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: smoothDecoration(
                    cornerRadius: 24,
                    color: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.secondaryCTA
                          : AppColors.grey100,
                    ),
                    shadows: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.shadowOverlay
                                  .withValues(alpha: 0.06),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppDateUtils.shortWeekdayName(date),
                        style: AppTextStyles.interMediumStyle500(
                          fontSize: 14,
                          fontColor: isSelected
                              ? AppColors.secondaryCTA
                              : AppColors.grey1000,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date.day.toString().padLeft(2, '0'),
                        style: AppTextStyles.interMediumStyle500(
                          fontSize: 14,
                          fontColor: isSelected
                              ? AppColors.secondaryCTA
                              : AppColors.grey1000,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
