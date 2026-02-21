import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:paw_around/models/public_pet/public_pet_profile.dart';

/// Returns [PublicPetProfile] by public ID for the unauthenticated public pet profile (web).
class PublicPetRepository {
  PublicPetRepository();

  static const String _collectionName = 'publicPetProfiles';

  /// Returns the public profile for the given [petPublicId], or null if not found.
  Future<PublicPetProfile?> getByPublicId(String petPublicId) async {
    if (petPublicId.isEmpty) return null;
    try {
      final doc = await FirebaseFirestore.instance
          .collection(_collectionName)
          .doc(petPublicId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data();
      return PublicPetProfile.fromMap(data);
    } catch (e) {
      // If Firestore read fails for any reason, treat as not found.
      // You can add logging here if desired.
      return null;
    }
  }
}
