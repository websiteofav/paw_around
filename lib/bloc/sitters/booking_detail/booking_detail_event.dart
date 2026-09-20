import 'package:equatable/equatable.dart';

abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object?> get props => [];
}

class CancelBookingRequested extends BookingDetailEvent {
  const CancelBookingRequested();
}

class RescheduleBookingRequested extends BookingDetailEvent {
  final DateTime scheduledDate;
  final String scheduledTimeSlot;

  const RescheduleBookingRequested({
    required this.scheduledDate,
    required this.scheduledTimeSlot,
  });

  @override
  List<Object?> get props => [scheduledDate, scheduledTimeSlot];
}
