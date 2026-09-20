import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_event.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_day_selector.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slot_grid.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Bottom sheet for picking a new day/time for an existing booking, reusing
/// the same day/time pickers from the Book Sitters form. Dispatches
/// RescheduleBookingRequested on the ambient BookingDetailBloc.
class RescheduleBottomSheet extends StatefulWidget {
  final BookingModel booking;

  const RescheduleBottomSheet({super.key, required this.booking});

  static Future<void> show({
    required BuildContext context,
    required BookingModel booking,
  }) {
    final bloc = context.read<BookingDetailBloc>();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: RescheduleBottomSheet(booking: booking),
      ),
    );
  }

  @override
  State<RescheduleBottomSheet> createState() => _RescheduleBottomSheetState();
}

class _RescheduleBottomSheetState extends State<RescheduleBottomSheet> {
  late int _selectedDayIndex;
  late String? _selectedTimeSlot;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final daysAhead = widget.booking.scheduledDate.difference(todayDate).inDays;
    _selectedDayIndex = daysAhead.clamp(0, 6);
    _selectedTimeSlot = widget.booking.scheduledTimeSlot;
  }

  void _onConfirm() {
    final scheduledDate = DateTime.now().add(Duration(days: _selectedDayIndex));
    context.read<BookingDetailBloc>().add(RescheduleBookingRequested(
          scheduledDate: scheduledDate,
          scheduledTimeSlot:
              _selectedTimeSlot ?? widget.booking.scheduledTimeSlot,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingDetailBloc, BookingDetailState>(
      // Only fires on the isRescheduling:true -> false edge, so it can't
      // mistake the sheet's initial state (also isRescheduling:false) for a
      // just-finished reschedule.
      listenWhen: (previous, current) =>
          previous is BookingDetailLoaded &&
          previous.isRescheduling &&
          current is BookingDetailLoaded,
      listener: (context, state) {
        final loaded = state as BookingDetailLoaded;
        if (loaded.rescheduleError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(AppStrings.failedToReschedule),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24),
        decoration: smoothDecoration(
          borderRadius: AppSmoothRadius.topOnly(24),
          color: AppColors.surface,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: smoothDecoration(
                      cornerRadius: 2, color: AppColors.border),
                ),
              ),
              Text(
                AppStrings.rescheduleTitle,
                style: AppTextStyles.semiBoldStyle600(
                    fontSize: 20, fontColor: AppColors.textPrimary),
              ),
              AppSpacing.vertical20,
              BookSittersDaySelector(
                selectedIndex: _selectedDayIndex,
                onSelect: (index) => setState(() => _selectedDayIndex = index),
              ),
              AppSpacing.vertical24,
              BookSittersTimeSlotGrid(
                selected: _selectedTimeSlot,
                onSelect: (slot) => setState(() => _selectedTimeSlot = slot),
              ),
              AppSpacing.vertical24,
              BlocBuilder<BookingDetailBloc, BookingDetailState>(
                builder: (context, state) {
                  final isRescheduling =
                      state is BookingDetailLoaded && state.isRescheduling;
                  return CommonButton(
                    text: AppStrings.confirmReschedule,
                    isLoading: isRescheduling,
                    onPressed: _onConfirm,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
