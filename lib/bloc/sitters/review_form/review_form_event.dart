import 'package:equatable/equatable.dart';

abstract class ReviewFormEvent extends Equatable {
  const ReviewFormEvent();

  @override
  List<Object?> get props => [];
}

class SubmitReview extends ReviewFormEvent {
  final String professionalId;
  final String bookingId;
  final int rating;
  final String? comment;

  const SubmitReview({
    required this.professionalId,
    required this.bookingId,
    required this.rating,
    this.comment,
  });

  @override
  List<Object?> get props => [professionalId, bookingId, rating, comment];
}
