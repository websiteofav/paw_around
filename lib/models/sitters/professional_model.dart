import 'package:cloud_firestore/cloud_firestore.dart';

/// A pet-sitting professional available for booking, stored at
/// `sitters/{id}`. `role`/`rating`/`reviewCount` are snapshotted onto a
/// BookingModel when a booking is created.
class ProfessionalModel {
  final String id;
  final String name;
  final bool isAvailable;
  final String role;
  final double rating;
  final int reviewCount;

  const ProfessionalModel({
    required this.id,
    required this.name,
    required this.isAvailable,
    required this.role,
    required this.rating,
    required this.reviewCount,
  });

  factory ProfessionalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProfessionalModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      isAvailable: data['isAvailable'] as bool? ?? true,
      role: data['role'] as String? ?? 'Pet Care Professional',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,
    );
  }
}
