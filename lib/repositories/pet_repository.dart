import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';

class PetRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  PetRepository({
    FirebaseFirestore? firestore,
    required AuthRepository authRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authRepository = authRepository;

  // Get reference to current user's pets collection
  CollectionReference<Map<String, dynamic>> get _petsRef {
    final userId = _authRepository.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('pets');
  }

  // Get all pets for current user
  Future<List<PetModel>> getAllPets() async {
    final snapshot = await _petsRef.orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
  }

  // Get pets stream for real-time updates
  Stream<List<PetModel>> getPetsStream() {
    return _petsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList(),
        );
  }

  // Get pet by ID
  Future<PetModel?> getPetById(String id) async {
    final doc = await _petsRef.doc(id).get();
    if (doc.exists) {
      return PetModel.fromFirestore(doc);
    }
    return null;
  }

  // Add pet
  Future<String> addPet(PetModel pet) async {
    final docRef = await _petsRef.add(pet.toFirestore());
    return docRef.id;
  }

  // Update pet
  Future<void> updatePet(PetModel pet) async {
    await _petsRef.doc(pet.id).update(pet.toFirestore());
  }

  // Delete pet
  Future<void> deletePet(String id) async {
    await _petsRef.doc(id).delete();
  }

  // Get pets by species
  Future<List<PetModel>> getPetsBySpecies(String species) async {
    final snapshot = await _petsRef.where('species', isEqualTo: species).get();
    return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
  }

  // Get pets with upcoming vaccines (within 30 days)
  Future<List<PetModel>> getPetsWithUpcomingVaccines() async {
    final pets = await getAllPets();
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return pets.where((pet) {
      return pet.vaccines.any((vaccine) {
        return vaccine.nextDueDate.isAfter(now) && vaccine.nextDueDate.isBefore(thirtyDaysFromNow);
      });
    }).toList();
  }

  // Get pets with overdue vaccines
  Future<List<PetModel>> getPetsWithOverdueVaccines() async {
    final pets = await getAllPets();
    final now = DateTime.now();

    return pets.where((pet) {
      return pet.vaccines.any((vaccine) => vaccine.nextDueDate.isBefore(now));
    }).toList();
  }

  // Get pet count
  Future<int> getPetCount() async {
    final snapshot = await _petsRef.count().get();
    return snapshot.count ?? 0;
  }

  // Clear all pets (use with caution)
  Future<void> clearAllPets() async {
    final snapshot = await _petsRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
