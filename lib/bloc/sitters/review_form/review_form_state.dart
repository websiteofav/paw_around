import 'package:equatable/equatable.dart';

abstract class ReviewFormState extends Equatable {
  const ReviewFormState();

  @override
  List<Object?> get props => [];
}

class ReviewFormInitial extends ReviewFormState {
  const ReviewFormInitial();
}

class ReviewFormSubmitting extends ReviewFormState {
  const ReviewFormSubmitting();
}

/// Transient signal that the review was just saved — listen for this to
/// drive one-off side effects (closing the sheet), not to render a screen.
class ReviewFormSuccess extends ReviewFormState {
  const ReviewFormSuccess();
}

class ReviewFormError extends ReviewFormState {
  final String message;

  const ReviewFormError({required this.message});

  @override
  List<Object?> get props => [message];
}
