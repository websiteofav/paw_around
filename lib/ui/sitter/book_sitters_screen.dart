import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_event.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/models/sitters/professional_model.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/ui/location/pick_location_screen.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_app_bar.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_form.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slider.dart';
import 'package:paw_around/ui/sitter/widgets/booking_reminder_helper.dart';

/// Booking/scheduling screen shown once an address has been picked (either
/// from the saved-address list or right after adding a new one).
///
/// "Book Sitters" persists a real BookingModel to Firestore via
/// BookingFormBloc, then opens UpcomingSessionScreen for the new booking.
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
  ProfessionalModel? _selectedProfessional;

  // Snapshot of the booking just submitted — the BookingFormBloc listener
  // uses it to schedule a reminder once BookingFormSuccess reports the id.
  BookingModel? _pendingBooking;

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
    final professional = _selectedProfessional;
    if (professional == null) {
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
    final scheduledDate = DateTime.now().add(Duration(days: _selectedDayIndex));
    final totalAmount = (professional.hourlyRate *
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

    _pendingBooking = booking;
    _bookingFormBloc.add(SubmitBooking(booking: booking));
  }

  Future<void> _onBookingSuccess(String bookingId) async {
    final booking = _pendingBooking;
    if (booking != null && mounted) {
      await BookingReminderHelper.scheduleForBooking(
        context: context,
        booking: booking,
        bookingId: bookingId,
      );
    }
    if (mounted) _navigateToUpcomingSession(bookingId);
  }

  void _navigateToUpcomingSession(String bookingId) {
    context.pushNamed(AppRoutes.upcomingSession, extra: bookingId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bookingFormBloc,
      child: BlocListener<BookingFormBloc, BookingFormState>(
        listener: (context, state) {
          if (state is BookingFormSuccess) {
            _onBookingSuccess(state.bookingId);
          } else if (state is BookingFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppStrings.failedToBookSitter),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: const BookSittersAppBar(),
          body: BookSittersForm(
            isScheduleSelected: _isScheduleSelected,
            onScheduleChanged: (value) =>
                setState(() => _isScheduleSelected = value),
            activeAddress: _activeAddress,
            onEditLocation: _onEditLocation,
            onAddNewAddress: _onAddNewAddress,
            onSwitchAddress: _onSwitchAddress,
            selectedDayIndex: _selectedDayIndex,
            onDaySelect: (index) => setState(() => _selectedDayIndex = index),
            selectedTimeSlot: _selectedTimeSlot,
            onTimeSlotSelect: (slot) =>
                setState(() => _selectedTimeSlot = slot),
            selectedProfessional: _selectedProfessional,
            onProfessionalSelect: (professional) =>
                setState(() => _selectedProfessional = professional),
            hours: _hours,
            onHoursChanged: (value) => setState(() => _hours = value),
            onBookSitters: _onBookSitters,
          ),
        ),
      ),
    );
  }
}
