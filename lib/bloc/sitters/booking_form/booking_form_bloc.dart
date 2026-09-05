import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_event.dart';
import 'package:paw_around/bloc/sitters/booking_form/booking_form_state.dart';
import 'package:paw_around/repositories/booking_repository.dart';

class BookingFormBloc extends Bloc<BookingFormEvent, BookingFormState> {
  final BookingRepository _bookingRepository;

  BookingFormBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(const BookingFormInitial()) {
    on<SubmitBooking>(_onSubmitBooking);
  }

  Future<void> _onSubmitBooking(
      SubmitBooking event, Emitter<BookingFormState> emit) async {
    emit(const BookingFormSubmitting());
    try {
      final id = await _bookingRepository.createBooking(event.booking);
      emit(BookingFormSuccess(bookingId: id));
    } catch (e) {
      emit(BookingFormError(message: e.toString()));
    }
  }
}
