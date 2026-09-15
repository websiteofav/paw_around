import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/sitters/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore;

  ReviewRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Writes a review under the sitter and folds it into that sitter's
  /// aggregate rating/reviewCount in the same transaction, so concurrent
  /// reviews of the same sitter can't corrupt the average.
  Future<void> submitReview({
    required String professionalId,
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final sitterRef = _firestore.collection('sitters').doc(professionalId);
    final reviewRef = sitterRef.collection('reviews').doc();
    final review = ReviewModel(
      id: reviewRef.id,
      bookingId: bookingId,
      rating: rating,
      comment: comment,
      createdAt: DateTime.now(),
    );

    await _firestore.runTransaction((txn) async {
      final sitterSnap = await txn.get(sitterRef);
      final data = sitterSnap.data() ?? {};
      final oldRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final oldCount = (data['reviewCount'] as num?)?.toInt() ?? 0;
      final newCount = oldCount + 1;
      final newRating = ((oldRating * oldCount) + rating) / newCount;

      txn.set(reviewRef, review.toFirestore());
      txn.update(sitterRef, {'rating': newRating, 'reviewCount': newCount});
    });
  }
}
