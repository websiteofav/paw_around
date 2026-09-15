import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/review_form/review_form_event.dart';
import 'package:paw_around/bloc/sitters/review_form/review_form_state.dart';
import 'package:paw_around/repositories/booking_repository.dart';
import 'package:paw_around/repositories/review_repository.dart';

class ReviewFormBloc extends Bloc<ReviewFormEvent, ReviewFormState> {
  final ReviewRepository _reviewRepository;
  final BookingRepository _bookingRepository;

  ReviewFormBloc({
    required ReviewRepository reviewRepository,
    required BookingRepository bookingRepository,
  })  : _reviewRepository = reviewRepository,
        _bookingRepository = bookingRepository,
        super(const ReviewFormInitial()) {
    on<SubmitReview>(_onSubmitReview);
  }

  Future<void> _onSubmitReview(
      SubmitReview event, Emitter<ReviewFormState> emit) async {
    emit(const ReviewFormSubmitting());
    try {
      await _reviewRepository.submitReview(
        professionalId: event.professionalId,
        bookingId: event.bookingId,
        rating: event.rating,
        comment: event.comment,
      );
      await _bookingRepository.markReviewed(event.bookingId);
      emit(const ReviewFormSuccess());
    } catch (e) {
      emit(ReviewFormError(message: e.toString()));
    }
  }
}
