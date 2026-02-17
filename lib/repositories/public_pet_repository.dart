import 'package:paw_around/models/public_pet/public_pet_last_seen.dart';
import 'package:paw_around/models/public_pet/public_pet_owner.dart';
import 'package:paw_around/models/public_pet/public_pet_profile.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

/// Returns [PublicPetProfile] by public ID for the unauthenticated public pet profile (web).
/// Currently uses mock data; replace with Firestore read from publicPetProfiles when available.
class PublicPetRepository {
  PublicPetRepository();

  static const String _mockPublicId = 'pet_mock1';

  /// Returns the public profile for the given [petPublicId], or null if not found.
  Future<PublicPetProfile?> getByPublicId(String petPublicId) async {
    if (petPublicId.isEmpty) return null;
    return _getMockProfile(petPublicId);
  }

  PublicPetProfile? _getMockProfile(String petPublicId) {
    if (petPublicId != _mockPublicId) return null;

    final now = DateTime.now();
    final dob = DateTime(now.year - 4, now.month, now.day);
    final lastSeenAt = now.subtract(const Duration(hours: 12));

    final vaccines = [
      VaccineModel(
        id: 'v1',
        vaccineName: 'Rabies',
        dateGiven: DateTime(now.year - 1, 1, 1),
        nextDueDate: DateTime(now.year + 1, 1, 1),
        notes: '',
        setReminder: true,
        snoozedUntil: null,
        createdAt: now,
        updatedAt: now,
        completionHistory: [DateTime(now.year - 1, 1, 1)],
      ),
    ];

    final pet = PetModel(
      id: 'mock-pet-1',
      name: 'Max',
      species: 'Dog',
      breed: 'Golden Retriever',
      gender: 'Male',
      dateOfBirth: dob,
      weight: 27,
      notes: 'Need to have water available.',
      imagePath: null,
      vaccines: vaccines,
      groomingSettings: null,
      tickFleaSettings: null,
      createdAt: now,
      updatedAt: now,
      petPublicId: _mockPublicId,
      isLost: true,
      lastSeenAt: lastSeenAt,
      lastSeenLocation: 'Central Park',
    );

    const owner = PublicPetOwner(
      name: 'John Doe',
      primaryPhone: '+919876543210',
    );

    return PublicPetProfile(
      pet: pet,
      owner: owner,
      lastSeen: PublicPetLastSeen(
        at: lastSeenAt,
        location: 'Central Park',
      ),
    );
  }
}
