import 'package:equatable/equatable.dart';
import 'package:paw_around/models/sitters/booking_model.dart';

abstract class BookingDetailState extends Equatable {
  const BookingDetailState();

  @override
  List<Object?> get props => [];
}

class BookingDetailLoading extends BookingDetailState {
  const BookingDetailLoading();
}

class BookingDetailLoaded extends BookingDetailState {
  final BookingModel booking;
  final bool isCancelling;
  final String? cancelError;

  const BookingDetailLoaded({
    required this.booking,
    this.isCancelling = false,
    this.cancelError,
  });

  @override
  List<Object?> get props => [booking, isCancelling, cancelError];
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}
