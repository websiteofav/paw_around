import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Single-line "clock icon + date/time + edit" row on the Booking Summary
/// screen — the date/time equivalent of BookSittersLocationCard.
class BookingSummaryDateRow extends StatelessWidget {
  final String dateTimeLabel;
  final VoidCallback onEdit;

  const BookingSummaryDateRow({
    super.key,
    required this.dateTimeLabel,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: smoothDecoration(
            cornerRadius: 10,
            color: AppColors.background3,
          ),
          padding: const EdgeInsets.all(8),
          child: Image.asset(
            AppIcons.sitterClockIcon,
            color: AppColors.black,
            colorBlendMode: BlendMode.srcIn,
          ),
        ),
        AppSpacing.horizontal12,
        Expanded(
          child: Text(
            dateTimeLabel,
            style: AppTextStyles.interBoldStyle700(
              fontSize: 16,
              fontColor: AppColors.grey1000,
            ),
          ),
        ),
        AppSpacing.horizontal12,
        GestureDetector(
          onTap: onEdit,
          child: SvgPicture.asset(
            AppIcons.editIcon,
            height: 20,
            colorFilter: const ColorFilter.mode(
              AppColors.secondaryCTA,
              BlendMode.srcIn,
            ),
          ),
        ),
      ],
    );
  }
}
