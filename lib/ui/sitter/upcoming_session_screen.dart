import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_session_card.dart';

/// Shows the booking summary after "Book Sitters" is tapped, live from
/// Firestore via [BookingDetailBloc].
class UpcomingSessionScreen extends StatelessWidget {
  final String bookingId;

  const UpcomingSessionScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BookingDetailBloc(
        bookingId: bookingId,
        bookingRepository: sl<BookingRepository>(),
      ),
      child: BlocListener<BookingDetailBloc, BookingDetailState>(
        listener: (context, state) {
          if (state is BookingDetailLoaded && state.cancelError != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.failedToCancelBooking),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: _buildAppBar(context),
          body: BlocBuilder<BookingDetailBloc, BookingDetailState>(
            builder: (context, state) {
              if (state is BookingDetailLoaded) {
                return UpcomingSessionCard(state: state);
              }
              if (state is BookingDetailError) {
                return const Center(child: Text(AppStrings.bookingNotFound));
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
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
        AppStrings.upcomingSessionTitle,
        style: AppTextStyles.semiBoldStyle600(
            fontSize: 18, fontColor: AppColors.textPrimary),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.headset_mic_rounded,
              color: AppColors.secondaryCTA),
          onPressed: () => context.pushNamed(AppRoutes.helpSupport),
        ),
      ],
    );
  }
}
