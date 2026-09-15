import 'package:cloud_firestore/cloud_firestore.dart';

/// A pet owner's review of a sitter after a session, stored at
/// `sitters/{sitterId}/reviews/{reviewId}`.
class ReviewModel {
  final String id;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      bookingId: data['bookingId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      comment: data['comment'] as String?,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}
