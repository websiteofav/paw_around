import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/sitters/booking_list/booking_list_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_list/booking_list_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/ui/sitter/widgets/booking_list_item.dart';
import 'package:paw_around/ui/widgets/empty_state_widget.dart';

/// All of the current user's sitter bookings, live from Firestore — tap
/// any one to reopen its Upcoming Session detail.
class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BookingListBloc(bookingRepository: sl<BookingRepository>()),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: _buildAppBar(context),
        body: BlocBuilder<BookingListBloc, BookingListState>(
          builder: (context, state) {
            if (state is BookingListLoaded) {
              if (state.bookings.isEmpty) {
                return const Center(
                  child: EmptyStateWidget(
                    icon: Icons.event_note_rounded,
                    title: AppStrings.noBookingsYetTitle,
                    subtitle: AppStrings.noBookingsYetSubtitle,
                  ),
                );
              }
              return ListView.separated(
                padding: AppEdgeInsets.allMedium,
                itemCount: state.bookings.length,
                separatorBuilder: (_, __) => AppSpacing.vertical12,
                itemBuilder: (context, index) {
                  final booking = state.bookings[index];
                  return BookingListItem(
                    booking: booking,
                    onTap: () => context.pushNamed(
                        AppRoutes.upcomingSession,
                        extra: booking.id),
                  );
                },
              );
            }
            if (state is BookingListError) {
              return const Center(
                  child: Text(AppStrings.failedToLoadBookings));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        AppStrings.myBookingsTitle,
        style: AppTextStyles.semiBoldStyle600(
            fontSize: 18, fontColor: AppColors.textPrimary),
      ),
      centerTitle: true,
    );
  }
}
