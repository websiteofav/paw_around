import 'package:equatable/equatable.dart';

abstract class BookingFormState extends Equatable {
  const BookingFormState();

  @override
  List<Object?> get props => [];
}

class BookingFormInitial extends BookingFormState {
  const BookingFormInitial();
}

class BookingFormSubmitting extends BookingFormState {
  const BookingFormSubmitting();
}

/// Transient signal that a booking was just created — listen for this to
/// drive one-off side effects (navigation), not to render a screen.
class BookingFormSuccess extends BookingFormState {
  final String bookingId;

  const BookingFormSuccess({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class BookingFormError extends BookingFormState {
  final String message;

  const BookingFormError({required this.message});

  @override
  List<Object?> get props => [message];
}
