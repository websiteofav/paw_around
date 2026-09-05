import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// "Select start time of service" grid on the Book Sitters screen — a
/// static list of slot times for now (no availability backend yet).
class BookSittersTimeSlotGrid extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const BookSittersTimeSlotGrid({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<String> _slots = [
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '4:00 PM',
    '6:00 PM',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.selectStartTimeOfService,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.6,
          children: _slots.map((slot) {
            final isSelected = slot == selected;
            return GestureDetector(
              onTap: () => onSelect(slot),
              child: Container(
                alignment: Alignment.center,
                decoration: smoothDecoration(
                  cornerRadius: 24,
                  color: AppColors.white,
                  side: BorderSide(color: isSelected ? AppColors.secondaryCTA : AppColors.grey100),
                  shadows: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: Text(slot,
                    style: isSelected
                        ? AppTextStyles.interBoldStyle700(
                            fontSize: 14,
                            fontColor: AppColors.secondaryCTA,
                          )
                        : AppTextStyles.interRegularStyle400(
                            fontSize: 14,
                            fontColor: AppColors.grey1000,
                          )),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
