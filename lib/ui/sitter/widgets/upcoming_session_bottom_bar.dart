import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Reschedule / Cancel Booking actions — sits inside the same white card as
/// the rest of the Upcoming Session screen. UI only — no booking backend
/// exists yet.
class UpcomingSessionBottomBar extends StatelessWidget {
  const UpcomingSessionBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CommonButton(
          text: AppStrings.reschedule,
          imagePath: AppIcons.sitterCalendarEditIcon,
          customColor: AppColors.secondaryCTA,
          customTextColor: AppColors.white,
          onPressed: () {},
          borderRadius: 44,
        ),
        AppSpacing.vertical12,
        CommonButton(
          text: AppStrings.cancelBooking,
          imagePath: AppIcons.sitterDeleteIcon,
          variant: ButtonVariant.outline,
          customColor: AppColors.error,
          customTextColor: AppColors.error,
          borderRadius: 44,
          onPressed: () {},
        ),
      ],
    );
  }
}
