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
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/repositories/professional_repository.dart';
import 'package:paw_around/ui/location/pick_location_screen.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_app_bar.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_form.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_time_slider.dart';
import 'package:paw_around/ui/sitter/widgets/booking_reminder_helper.dart';
import 'package:paw_around/ui/sitter/widgets/booking_submit_helper.dart';
import 'package:paw_around/ui/sitter/widgets/upcoming_booking_banner.dart';
import 'package:paw_around/utils/app_utils.dart';

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
  double _hours = 2.5;
  int _selectedDayIndex = 0;
  String? _selectedTimeSlot = '7:00 AM';
  ProfessionalModel? _selectedProfessional;
  bool _isProcessingPayment = false;

  // Defaults to showing the picker; flips to false only once we've
  // confirmed the user has no prior bookings AND successfully
  // auto-assigned an available professional for them.
  bool _showProfessionalSelector = true;

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
  void initState() {
    super.initState();
    _initProfessionalDefault();
  }

  // First-time users (no prior bookings) skip the picker and get
  // auto-assigned the first available professional; returning users still
  // choose, so they can pick the same sitter again or try someone new.
  Future<void> _initProfessionalDefault() async {
    final hasPrevious = await sl<BookingRepository>().hasAnyBooking();
    if (!mounted || hasPrevious) return;

    final professionals = await sl<ProfessionalRepository>().getAllProfessionals();
    if (!mounted) return;
    ProfessionalModel? autoAssigned;
    for (final p in professionals) {
      if (p.isAvailable) {
        autoAssigned = p;
        break;
      }
    }
    if (autoAssigned == null) return; // fall back to manual selection

    setState(() {
      _showProfessionalSelector = false;
      _selectedProfessional = autoAssigned;
    });
  }

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

  void _showError(String message) {
    AppUtils.showErrorSnackBar(context, message);
  }

  Future<void> _onBookSitters() async {
    final professional = _selectedProfessional;
    if (professional == null) {
      _showError(AppStrings.pleaseSelectProfessional);
      return;
    }
    final petListState = context.read<PetListBloc>().state;
    final selectedPet =
        petListState is PetListLoaded ? petListState.selectedPet : null;
    if (selectedPet == null) {
      _showError(AppStrings.noPetToBookSitterFor);
      return;
    }
    final scheduledDate = DateTime.now().add(Duration(days: _selectedDayIndex));
    final totalAmount = (professional.hourlyRate *
            _hours *
            (1 - BookSittersTimeSlider.discount))
        .round();

    setState(() => _isProcessingPayment = true);
    final booking = await BookingSubmitHelper.collectBookingAfterPayment(
      context: context,
      address: _activeAddress,
      professional: professional,
      pet: selectedPet,
      scheduledDate: scheduledDate,
      scheduledTimeSlot: _selectedTimeSlot ?? '7:00 AM',
      hours: _hours,
      totalAmount: totalAmount,
      contactPhone: sl<AuthRepository>().currentUser?.phoneNumber,
    );
    if (!mounted) return;
    setState(() => _isProcessingPayment = false);
    if (booking == null) return;

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
    if (mounted) {
      context.pushNamed(AppRoutes.upcomingSession, extra: bookingId);
    }
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
            _showError(AppStrings.failedToBookSitter);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          appBar: const BookSittersAppBar(),
          body: Column(
            children: [
              const UpcomingBookingBanner(),
              Expanded(
                child: BookSittersForm(
                  activeAddress: _activeAddress,
                  onEditLocation: _onEditLocation,
                  onAddNewAddress: _onAddNewAddress,
                  onSwitchAddress: _onSwitchAddress,
                  selectedDayIndex: _selectedDayIndex,
                  onDaySelect: (index) =>
                      setState(() => _selectedDayIndex = index),
                  selectedTimeSlot: _selectedTimeSlot,
                  onTimeSlotSelect: (slot) =>
                      setState(() => _selectedTimeSlot = slot),
                  selectedProfessional: _selectedProfessional,
                  onProfessionalSelect: (professional) =>
                      setState(() => _selectedProfessional = professional),
                  showProfessionalSelector: _showProfessionalSelector,
                  hours: _hours,
                  onHoursChanged: (value) => setState(() => _hours = value),
                  isProcessingPayment: _isProcessingPayment,
                  onBookSitters: _onBookSitters,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
