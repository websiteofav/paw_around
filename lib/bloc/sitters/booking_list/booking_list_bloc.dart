import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_list/booking_list_event.dart';
import 'package:paw_around/bloc/sitters/booking_list/booking_list_state.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/repositories/booking_repository.dart';

class _BookingsUpdated extends BookingListEvent {
  final List<BookingModel> bookings;

  const _BookingsUpdated(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class _BookingsStreamFailed extends BookingListEvent {
  final String message;

  const _BookingsStreamFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Streams all of the current user's bookings for the My Bookings screen.
class BookingListBloc extends Bloc<BookingListEvent, BookingListState> {
  final BookingRepository _bookingRepository;
  StreamSubscription<List<BookingModel>>? _subscription;

  BookingListBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(const BookingListLoading()) {
    on<_BookingsUpdated>((event, emit) =>
        emit(BookingListLoaded(bookings: event.bookings)));
    on<_BookingsStreamFailed>(
        (event, emit) => emit(BookingListError(message: event.message)));

    _subscription = _bookingRepository.bookingsStream().listen(
          (bookings) => add(_BookingsUpdated(bookings)),
          onError: (Object e) => add(_BookingsStreamFailed(e.toString())),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
