import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// Pinned above the booking form on the Sitter tab, in-app, whenever
/// there's a confirmed upcoming session — the "your order is on its way"
/// style persistent bar (Zomato/Urban Company), scoped to this screen
/// rather than a system notification. Renders nothing otherwise.
class UpcomingBookingBanner extends StatelessWidget {
  const UpcomingBookingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<BookingModel>>(
      stream: sl<BookingRepository>().bookingsStream(),
      builder: (context, snapshot) {
        final bookings = snapshot.data;
        if (bookings == null) return const SizedBox.shrink();

        final upcoming = bookings.where((b) => b.isUpcoming).toList()
          ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));
        if (upcoming.isEmpty) return const SizedBox.shrink();

        final next = upcoming.first;
        return Padding(
          padding: AppEdgeInsets.horizontalLarge.copyWith(top: 12, bottom: 4),
          child: ScaleButton(
            onPressed: () => context.pushNamed(
              AppRoutes.upcomingSession,
              extra: next.id,
            ),
            child: Container(
              padding: AppEdgeInsets.cardPadding,
              decoration: smoothDecoration(
                cornerRadius: 16,
                color: AppColors.background3,
                side: const BorderSide(color: AppColors.secondaryCTA),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded,
                      color: AppColors.secondaryCTA, size: 24),
                  AppSpacing.horizontal12,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.upcomingSessionTitle,
                          style: AppTextStyles.interBoldStyle700(
                            fontSize: 14,
                            fontColor: AppColors.grey1000,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${next.professionalName} • ${next.sessionDayLabel} at ${next.scheduledTimeSlot}',
                          style: AppTextStyles.interRegularStyle400(
                            fontSize: 12,
                            fontColor: AppColors.grey600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: AppColors.secondaryCTA, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
