import 'package:equatable/equatable.dart';
import 'package:paw_around/models/sitters/booking_model.dart';

abstract class BookingFormEvent extends Equatable {
  const BookingFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitBooking extends BookingFormEvent {
  final BookingModel booking;

  const SubmitBooking({required this.booking});

  @override
  List<Object?> get props => [booking];
}
