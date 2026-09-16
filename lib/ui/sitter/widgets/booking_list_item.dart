import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/booking_model.dart';

/// One row on the My Bookings screen — tap to open its Upcoming Session
/// detail.
class BookingListItem extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;

  const BookingListItem({super.key, required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppEdgeInsets.cardPaddingSmall,
        decoration: smoothDecoration(
          cornerRadius: 20,
          color: AppColors.white,
          side: const BorderSide(color: AppColors.grey100),
          shadows: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildAvatar(),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${booking.petName} · ${booking.professionalName}',
                    style: AppTextStyles.interBoldStyle700(
                        fontSize: 15, fontColor: AppColors.grey1000),
                  ),
                  AppSpacing.vertical4,
                  Text(
                    '${booking.sessionDayLabel} · ${booking.scheduledTimeSlot}',
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontal8,
            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final imagePath = booking.petImagePath;
    if (imagePath == null || imagePath.isEmpty || !imagePath.startsWith('http')) {
      return const CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.iconBgLight,
        child: Icon(Icons.pets, color: AppColors.primaryDark, size: 20),
      );
    }
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.iconBgLight,
      foregroundImage: CachedNetworkImageProvider(imagePath),
    );
  }

  Widget _buildStatusBadge() {
    final isCancelled = booking.isCancelled;
    final label = isCancelled
        ? AppStrings.bookingCancelledLabel
        : AppStrings.confirmedLabel;
    final color = isCancelled ? AppColors.error : AppColors.confirmedGreen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: smoothDecoration(
        cornerRadius: 999,
        color: color.withValues(alpha: 0.1),
      ),
      child: Text(
        label,
        style: AppTextStyles.interSemiBoldStyle600(fontSize: 11, fontColor: color),
      ),
    );
  }
}
