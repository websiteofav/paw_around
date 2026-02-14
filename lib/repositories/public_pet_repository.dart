import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

/// Returns [PetModel] by public ID for the unauthenticated public pet profile (web).
/// Currently uses mock data; replace with Firestore/public API when available.
class PublicPetRepository {
  PublicPetRepository();

  static const String _mockPublicId = 'pet_mock1';

  /// Returns the pet for the given [petPublicId], or null if not found.
  Future<PetModel?> getByPublicId(String petPublicId) async {
    if (petPublicId.isEmpty) return null;
    return _getMockPet(petPublicId);
  }

  PetModel? _getMockPet(String petPublicId) {
    if (petPublicId != _mockPublicId) return null;

    final now = DateTime.now();
    final dob = DateTime(now.year - 4, now.month, now.day);

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

    return PetModel(
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
    );
  }
}
