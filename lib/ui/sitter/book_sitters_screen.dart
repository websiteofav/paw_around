import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/location/pick_location_screen.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_day_selector.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_location_section.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_professional_selector.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_schedule_toggle.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slider.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slot_grid.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// Booking/scheduling screen shown once an address has been picked (either
/// from the saved-address list or right after adding a new one).
///
/// UI only — no sitter/professional/pricing/availability/booking backend
/// exists anywhere in this app yet, so every selector here updates purely
/// local state and "Book Sitters" has no real submission target. See the
/// TODO on [_onBookSitters].
class BookSittersScreen extends StatefulWidget {
  final AddressModel address;

  const BookSittersScreen({super.key, required this.address});

  @override
  State<BookSittersScreen> createState() => _BookSittersScreenState();
}

class _BookSittersScreenState extends State<BookSittersScreen> {
  bool _isScheduleSelected = true;
  double _hours = 2.5;
  int _selectedDayIndex = 0;
  String? _selectedTimeSlot = '7:00 AM';
  String? _selectedProfessionalId;

  // Defaults to whatever address Dashboard picked (most recently added),
  // but "Switch address" below can override it for this session.
  AddressModel? _selectedAddress;

  AddressModel get _activeAddress => _selectedAddress ?? widget.address;

  void _onEditLocation() {
    context.pushNamed(
      AppRoutes.pickLocation,
      extra: PickLocationArgs(
        initialLatitude: _activeAddress.latitude,
        initialLongitude: _activeAddress.longitude,
        initialAddress: _activeAddress.fullAddress,
      ),
    );
  }

  void _onAddNewAddress() {
    context.pushNamed(AppRoutes.pickLocation);
  }

  void _onSwitchAddress(AddressModel address) {
    setState(() => _selectedAddress = address);
  }

  void _onBookSitters() {
    // TODO: submit booking once a booking backend exists.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          AppStrings.petSittersTitle,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 18,
            fontColor: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppEdgeInsets.horizontalLarge,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSpacing.vertical20,
              BookSittersScheduleToggle(
                isScheduleSelected: _isScheduleSelected,
                onChanged: (value) => setState(() => _isScheduleSelected = value),
              ),
              AppSpacing.vertical36,
              BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
                  final addresses = state is AddressLoaded ? state.addresses : <AddressModel>[_activeAddress];
                  return BookSittersLocationSection(
                    selectedAddress: _activeAddress,
                    addresses: addresses,
                    onEdit: _onEditLocation,
                    onAddNewAddress: _onAddNewAddress,
                    onSwitchAddress: _onSwitchAddress,
                  );
                },
              ),
              AppSpacing.vertical24,
              BookSittersTimeSlider(
                hours: _hours,
                onChanged: (value) => setState(() => _hours = value),
              ),
              AppSpacing.vertical36,
              const Divider(color: AppColors.grey100),
              AppSpacing.vertical36,

              BookSittersDaySelector(
                selectedIndex: _selectedDayIndex,
                onSelect: (index) => setState(() => _selectedDayIndex = index),
              ),
              AppSpacing.vertical36,
              BookSittersTimeSlotGrid(
                selected: _selectedTimeSlot,
                onSelect: (slot) => setState(() => _selectedTimeSlot = slot),
              ),
              AppSpacing.vertical36,
              const Divider(color: AppColors.grey100),
              AppSpacing.vertical36,
              BookSittersProfessionalSelector(
                selectedId: _selectedProfessionalId,
                onSelect: (id) => setState(() => _selectedProfessionalId = id),
              ),
              AppSpacing.vertical32,
              CommonButton(
                text: AppStrings.bookSittersButton,
                onPressed: _onBookSitters,
                customColor: AppColors.primary,
                textStyle: AppTextStyles.interBoldStyle700(fontSize: 16, fontColor: AppColors.grey1000),
                customTextColor: AppColors.grey1000,
              ),
              // Clears Dashboard's floating bottom nav bar shown here too.
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
