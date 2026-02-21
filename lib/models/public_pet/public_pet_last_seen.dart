import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Last-seen info for a lost pet (when and where).
class PublicPetLastSeen extends Equatable {
  final DateTime? at;
  final String? location;

  const PublicPetLastSeen({
    this.at,
    this.location,
  });

  static PublicPetLastSeen? fromMap(Map<String, dynamic>? map) {
    if (map == null || map.isEmpty) return null;
    DateTime? at;
    final atValue = map['at'];
    if (atValue != null) {
      if (atValue is Timestamp) {
        at = atValue.toDate();
      } else if (atValue is String) {
        at = DateTime.tryParse(atValue);
      }
    }
    return PublicPetLastSeen(
      at: at,
      location: map['location'] as String?,
    );
  }

  @override
  List<Object?> get props => [at, location];
}
