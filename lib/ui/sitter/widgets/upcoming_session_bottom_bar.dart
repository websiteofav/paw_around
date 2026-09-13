import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Reschedule / Cancel Booking actions — sits inside the same white card as
/// the rest of the Upcoming Session screen. Hidden once the booking is
/// already cancelled.
class UpcomingSessionBottomBar extends StatelessWidget {
  final bool isCancelling;
  final VoidCallback onReschedule;
  final VoidCallback onCancel;

  const UpcomingSessionBottomBar({
    super.key,
    required this.isCancelling,
    required this.onReschedule,
    required this.onCancel,
  });

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
          onPressed: isCancelling ? null : onReschedule,
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
          isLoading: isCancelling,
          onPressed: isCancelling ? null : onCancel,
        ),
      ],
    );
  }
}
