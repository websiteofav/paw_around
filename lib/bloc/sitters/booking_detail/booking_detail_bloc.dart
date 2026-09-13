import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_event.dart';
import 'package:paw_around/bloc/sitters/booking_detail/booking_detail_state.dart';
import 'package:paw_around/models/sitters/booking_model.dart';
import 'package:paw_around/repositories/booking_repository.dart';

class _BookingUpdated extends BookingDetailEvent {
  final BookingModel booking;

  const _BookingUpdated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class _BookingStreamFailed extends BookingDetailEvent {
  final String message;

  const _BookingStreamFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Streams a single booking from Firestore for the Upcoming Session screen,
/// and handles cancelling it. The stream itself carries the post-cancel
/// state back in, so [CancelBookingRequested] doesn't need to update local
/// state on success.
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final BookingRepository _bookingRepository;
  final String bookingId;
  StreamSubscription<BookingModel>? _subscription;

  BookingDetailBloc({
    required this.bookingId,
    required BookingRepository bookingRepository,
  })  : _bookingRepository = bookingRepository,
        super(const BookingDetailLoading()) {
    on<_BookingUpdated>(_onBookingUpdated);
    on<_BookingStreamFailed>(_onBookingStreamFailed);
    on<CancelBookingRequested>(_onCancelRequested);

    _subscription = _bookingRepository.bookingStream(bookingId).listen(
          (booking) => add(_BookingUpdated(booking)),
          onError: (Object e) => add(_BookingStreamFailed(e.toString())),
        );
  }

  void _onBookingUpdated(_BookingUpdated event, Emitter<BookingDetailState> emit) {
    emit(BookingDetailLoaded(booking: event.booking));
  }

  void _onBookingStreamFailed(_BookingStreamFailed event, Emitter<BookingDetailState> emit) {
    emit(BookingDetailError(message: event.message));
  }

  Future<void> _onCancelRequested(
      CancelBookingRequested event, Emitter<BookingDetailState> emit) async {
    final current = state;
    if (current is! BookingDetailLoaded || current.isCancelling) return;
    emit(BookingDetailLoaded(booking: current.booking, isCancelling: true));
    try {
      await _bookingRepository.cancelBooking(bookingId);
    } catch (e) {
      emit(BookingDetailLoaded(
        booking: current.booking,
        cancelError: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
