import 'package:equatable/equatable.dart';
import 'package:paw_around/models/sitters/booking_model.dart';

abstract class BookingListState extends Equatable {
  const BookingListState();

  @override
  List<Object?> get props => [];
}

class BookingListLoading extends BookingListState {
  const BookingListLoading();
}

class BookingListLoaded extends BookingListState {
  final List<BookingModel> bookings;

  const BookingListLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingListError extends BookingListState {
  final String message;

  const BookingListError({required this.message});

  @override
  List<Object?> get props => [message];
}
