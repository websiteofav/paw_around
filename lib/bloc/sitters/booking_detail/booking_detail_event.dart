import 'package:equatable/equatable.dart';

abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

class CancelBookingRequested extends BookingDetailEvent {
  const CancelBookingRequested();
}
