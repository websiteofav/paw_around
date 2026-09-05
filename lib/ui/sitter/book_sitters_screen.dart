import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/addresses/address/address_bloc.dart';
import 'package:paw_around/bloc/addresses/address/address_state.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_event.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/models/sitters/professional_model.dart';
import 'package:paw_around/models/sitters/upcoming_session_model.dart';
import 'package:paw_around/repositories/booking_repository.dart';
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
/// "Book Sitters" persists a real BookingModel to Firestore via
/// BookingFormBloc, then opens the mock UpcomingSessionScreen — the
/// Upcoming Session screen itself doesn't read from Firestore yet, that's
/// a follow-up. See BookingModel's doc comment.
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

  late final BookingFormBloc _bookingFormBloc =
      BookingFormBloc(bookingRepository: sl<BookingRepository>());

  AddressModel get _activeAddress => _selectedAddress ?? widget.address;

  @override
  void dispose() {
    _bookingFormBloc.close();
    super.dispose();
  }

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
    if (_selectedProfessionalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.pleaseSelectProfessional),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final petListState = context.read<PetListBloc>().state;
    final selectedPet =
        petListState is PetListLoaded ? petListState.selectedPet : null;
    if (selectedPet == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(AppStrings.noPetToBookSitterFor),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    final professional = ProfessionalModel.mockProfessionals
        .firstWhere((p) => p.id == _selectedProfessionalId);
    final scheduledDate = DateTime.now().add(Duration(days: _selectedDayIndex));
    final totalAmount = (BookSittersTimeSlider.ratePerHour *
            _hours *
            (1 - BookSittersTimeSlider.discount))
        .round();

    final booking = BookingModel.create(
      petId: selectedPet.id,
      petName: selectedPet.name,
      petBreed: selectedPet.breed,
      petAgeLabel: selectedPet.ageString,
      petImagePath: selectedPet.imagePath,
      professionalId: professional.id,
      professionalName: professional.name,
      professionalRole: professional.role,
      professionalRating: professional.rating,
      professionalReviewCount: professional.reviewCount,
      addressLabel: _activeAddress.label,
      addressText: _activeAddress.fullAddress,
      scheduledDate: scheduledDate,
      scheduledTimeSlot: _selectedTimeSlot ?? '7:00 AM',
      durationHours: _hours,
      totalAmount: totalAmount,
    );

    _bookingFormBloc.add(SubmitBooking(booking: booking));
  }

  // The Upcoming Session screen doesn't read from Firestore yet (follow-up
  // task) — it still takes a client-only UpcomingSessionModel, built here
  // from the same real pet used for the just-persisted BookingModel.
  void _navigateToUpcomingSession() {
    final petListState = context.read<PetListBloc>().state;
    final selectedPet =
        petListState is PetListLoaded ? petListState.selectedPet : null;
    const mock = UpcomingSessionModel.mockAssignedSession;
    context.pushNamed(
      AppRoutes.upcomingSession,
      extra: selectedPet == null
          ? mock
          : UpcomingSessionModel(
              petName: selectedPet.name,
              petBreed: selectedPet.breed,
              petAgeLabel: selectedPet.ageString,
              petImagePath: selectedPet.imagePath,
              sitterName: mock.sitterName,
              sitterRole: mock.sitterRole,
              sitterRating: mock.sitterRating,
              sitterReviewCount: mock.sitterReviewCount,
              confirmedDateLabel: mock.confirmedDateLabel,
              sessionDayLabel: mock.sessionDayLabel,
              sessionTimeLabel: mock.sessionTimeLabel,
              startsInLabel: mock.startsInLabel,
              locationLabel: mock.locationLabel,
              locationAddress: mock.locationAddress,
              totalAmount: mock.totalAmount,
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingFormBloc,
      child: BlocListener<BookingFormBloc, BookingFormState>(
        listener: (context, state) {
          if (state is BookingFormSuccess) {
            _navigateToUpcomingSession();
          } else if (state is BookingFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.failedToBookSitter),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: _buildScaffold(),
      ),
    );
  }

  Widget _buildScaffold() {
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
                onChanged: (value) =>
                    setState(() => _isScheduleSelected = value),
              ),
              AppSpacing.vertical36,
              BlocBuilder<AddressBloc, AddressState>(
                builder: (context, state) {
                  final addresses = state is AddressLoaded
                      ? state.addresses
                      : <AddressModel>[_activeAddress];
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
              BlocBuilder<BookingFormBloc, BookingFormState>(
                builder: (context, state) {
                  final isSubmitting = state is BookingFormSubmitting;
                  return CommonButton(
                    text: AppStrings.bookSittersButton,
                    onPressed: _onBookSitters,
                    isLoading: isSubmitting,
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
      ),
    );
  }
}
