import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/models/sitters/professional_model.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_day_selector.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_location_section.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_professional_selector.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slider.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slot_grid.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// The scrollable body of BookSittersScreen — schedule toggle, location,
/// day/time, professional, and pricing sections. Price only shows once a
/// professional is picked, since rates are per-professional.
class BookSittersForm extends StatelessWidget {
  final AddressModel activeAddress;
  final VoidCallback onEditLocation;
  final VoidCallback onAddNewAddress;
  final ValueChanged<AddressModel> onSwitchAddress;
  final int selectedDayIndex;
  final ValueChanged<int> onDaySelect;
  final String? selectedTimeSlot;
  final ValueChanged<String> onTimeSlotSelect;
  final ProfessionalModel? selectedProfessional;
  final ValueChanged<ProfessionalModel> onProfessionalSelect;
  final double hours;
  final ValueChanged<double> onHoursChanged;
  final VoidCallback onBookSitters;
  final bool isProcessingPayment;

  const BookSittersForm({
    super.key,
    required this.activeAddress,
    required this.onEditLocation,
    required this.onAddNewAddress,
    required this.onSwitchAddress,
    required this.selectedDayIndex,
    required this.onDaySelect,
    required this.selectedTimeSlot,
    required this.onTimeSlotSelect,
    required this.selectedProfessional,
    required this.onProfessionalSelect,
    required this.hours,
    required this.onHoursChanged,
    required this.onBookSitters,
    required this.isProcessingPayment,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: AppEdgeInsets.horizontalLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppSpacing.vertical20,
            BlocBuilder<AddressBloc, AddressState>(
              builder: (context, state) {
                final addresses = state is AddressLoaded
                    ? state.addresses
                    : <AddressModel>[activeAddress];
                return BookSittersLocationSection(
                  selectedAddress: activeAddress,
                  addresses: addresses,
                  onEdit: onEditLocation,
                  onAddNewAddress: onAddNewAddress,
                  onSwitchAddress: onSwitchAddress,
                );
              },
            ),
            AppSpacing.vertical24,
            const Divider(color: AppColors.grey100),
            AppSpacing.vertical36,
            BookSittersDaySelector(
              selectedIndex: selectedDayIndex,
              onSelect: onDaySelect,
            ),
            AppSpacing.vertical36,
            BookSittersTimeSlotGrid(
              selected: selectedTimeSlot,
              onSelect: onTimeSlotSelect,
            ),
            AppSpacing.vertical36,
            const Divider(color: AppColors.grey100),
            AppSpacing.vertical36,
            BookSittersProfessionalSelector(
              selected: selectedProfessional,
              onSelect: onProfessionalSelect,
            ),
            AppSpacing.vertical36,
            const Divider(color: AppColors.grey100),
            AppSpacing.vertical36,
            if (selectedProfessional != null)
              BookSittersTimeSlider(
                hours: hours,
                ratePerHour: selectedProfessional!.hourlyRate,
                onChanged: onHoursChanged,
              )
            else
              Text(
                AppStrings.selectProfessionalForPricing,
                style: AppTextStyles.interRegularStyle400(
                    fontSize: 14, fontColor: AppColors.grey600),
              ),
            AppSpacing.vertical32,
            BlocBuilder<BookingFormBloc, BookingFormState>(
              builder: (context, state) {
                final isBusy =
                    isProcessingPayment || state is BookingFormSubmitting;
                return CommonButton(
                  text: isProcessingPayment
                      ? AppStrings.processingPayment
                      : AppStrings.bookSittersButton,
                  onPressed: isBusy ? null : onBookSitters,
                  isLoading: isBusy,
                  customColor: AppColors.primary,
                  textStyle: AppTextStyles.interBoldStyle700(
                      fontSize: 16, fontColor: AppColors.grey1000),
                  customTextColor: AppColors.grey1000,
                );
              },
            ),
            // Clears Dashboard's floating bottom nav bar shown here too.
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }
}
