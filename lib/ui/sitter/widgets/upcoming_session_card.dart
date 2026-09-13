import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_event.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/ui/sitter/widgets/cancel_booking_dialog.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_bottom_bar.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_detail_row.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_pet_row.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_sitter_section.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';

/// The white rounded-card body of the Upcoming Session screen — status
/// banner, pet/sitter/date/location/amount rows, and the reschedule/cancel
/// actions.
class UpcomingSessionCard extends StatelessWidget {
  final BookingDetailLoaded state;

  const UpcomingSessionCard({super.key, required this.state});

  BookingModel get booking => state.booking;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppEdgeInsets.horizontalMedium,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: smoothDecoration(
          cornerRadius: 36,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.grey100),
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.051),
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.039),
              blurRadius: 13,
              offset: const Offset(0, 13),
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.031),
              blurRadius: 18,
              offset: const Offset(0, 30),
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.012),
              blurRadius: 21,
              offset: const Offset(0, 54),
            ),
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.0),
              blurRadius: 23,
              offset: const Offset(0, 84),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusBanner(),
            Padding(
              padding: AppEdgeInsets.allMedium,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UpcomingSessionPetRow(booking: booking),
                  AppSpacing.vertical20,
                  UpcomingSessionSitterSection(booking: booking),
                  _divider(),
                  UpcomingSessionDetailRow(
                    iconAsset: AppIcons.sitterClockIcon,
                    title:
                        '${booking.sessionDayLabel} - ${booking.scheduledTimeSlot}',
                    subtitle: booking.startsInLabel,
                  ),
                  _divider(),
                  UpcomingSessionDetailRow(
                    iconAsset: AppIcons.sitterHomePinIcon,
                    title: booking.addressLabel,
                    subtitle: booking.addressText,
                    trailingLabel: AppStrings.viewOnMap,
                    onTrailingTap: () {},
                  ),
                  _divider(),
                  UpcomingSessionDetailRow(
                    iconAsset: AppIcons.sitterCardIcon,
                    title:
                        '₹${booking.totalAmount} ${AppStrings.totalAmountSuffix}',
                    trailingLabel: AppStrings.viewBreakdown,
                    onTrailingTap: () {},
                  ),
                  _divider(),
                  AppSpacing.vertical16,
                  InfoBanner(
                    text:
                        '${booking.professionalName} ${AppStrings.sitterWillArriveSuffix}',
                  ),
                  AppSpacing.vertical24,
                  if (!booking.isCancelled)
                    UpcomingSessionBottomBar(
                      isCancelling: state.isCancelling,
                      onReschedule: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(AppStrings.rescheduleComingSoon)),
                        );
                      },
                      onCancel: () => CancelBookingDialog.show(
                        context: context,
                        onConfirm: () => context
                            .read<BookingDetailBloc>()
                            .add(const CancelBookingRequested()),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    final isCancelled = booking.isCancelled;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(36),
        color: isCancelled ? AppColors.error : AppColors.confirmedGreen,
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isCancelled ? Icons.cancel : Icons.check_circle,
              size: 18, color: AppColors.white),
          AppSpacing.horizontal8,
          Text(
            isCancelled
                ? AppStrings.bookingCancelledLabel
                : '${AppStrings.confirmedForPrefix} ${booking.confirmedDateLabel}',
            style: AppTextStyles.interSemiBoldStyle600(
                fontSize: 12, fontColor: AppColors.white),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: AppColors.grey100, height: 1),
    );
  }
}
