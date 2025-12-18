import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
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

  // Update grooming settings for a pet
  Future<void> updateGroomingSettings(String petId, CareSettingsModel settings) async {
    await _petsRef.doc(petId).update({
      'groomingSettings': settings.toFirestore(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Update tick & flea settings for a pet
  Future<void> updateTickFleaSettings(String petId, CareSettingsModel settings) async {
    await _petsRef.doc(petId).update({
      'tickFleaSettings': settings.toFirestore(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Update or add a vaccine for a pet
  Future<void> updateVaccine(String petId, VaccineModel vaccine) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final updatedVaccines = List<VaccineModel>.from(pet.vaccines);
    final existingIndex = updatedVaccines.indexWhere(
      (v) => v.vaccineName.toLowerCase() == vaccine.vaccineName.toLowerCase(),
    );

    if (existingIndex >= 0) {
      // Update existing vaccine
      updatedVaccines[existingIndex] = vaccine;
    } else {
      // Add new vaccine
      updatedVaccines.add(vaccine);
    }

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Get pets with upcoming grooming (due within 7 days)
  Future<List<PetModel>> getPetsWithUpcomingGrooming() async {
    final pets = await getAllPets();
    return pets.where((pet) {
      return pet.groomingSettings?.isDueSoon == true || pet.groomingSettings?.isOverdue == true;
    }).toList();
  }

  // Get pets with upcoming tick/flea treatment (due within 7 days)
  Future<List<PetModel>> getPetsWithUpcomingTickFlea() async {
    final pets = await getAllPets();
    return pets.where((pet) {
      return pet.tickFleaSettings?.isDueSoon == true || pet.tickFleaSettings?.isOverdue == true;
    }).toList();
  }

  // Mark vaccine as done - updates dateGiven and recalculates nextDueDate
  Future<void> markVaccineAsDone(String petId, String vaccineId) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final updatedVaccines = pet.vaccines.map((v) {
      if (v.id == vaccineId) {
        final now = DateTime.now();
        // Calculate next due date based on original interval
        final originalInterval = v.nextDueDate.difference(v.dateGiven).inDays;
        return v.copyWith(
          dateGiven: now,
          nextDueDate: now.add(Duration(days: originalInterval > 0 ? originalInterval : 365)),
          snoozedUntil: null,
          updatedAt: now,
        );
      }
      return v;
    }).toList();

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Snooze vaccine for specified days
  Future<void> snoozeVaccine(String petId, String vaccineId, int days) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final snoozedUntil = DateTime.now().add(Duration(days: days));
    final updatedVaccines = pet.vaccines.map((v) {
      if (v.id == vaccineId) {
        return v.copyWith(
          snoozedUntil: snoozedUntil,
          updatedAt: DateTime.now(),
        );
      }
      return v;
    }).toList();

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Mark grooming as done
  Future<void> markGroomingAsDone(String petId) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings == null) {
      return;
    }

    final updatedSettings = pet.groomingSettings!.copyWith(
      lastDate: DateTime.now(),
      snoozedUntil: null,
      updatedAt: DateTime.now(),
    );

    await updateGroomingSettings(petId, updatedSettings);
  }

  // Snooze grooming for specified days
  Future<void> snoozeGrooming(String petId, int days) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings == null) {
      return;
    }

    final updatedSettings = pet.groomingSettings!.copyWith(
      snoozedUntil: DateTime.now().add(Duration(days: days)),
      updatedAt: DateTime.now(),
    );

    await updateGroomingSettings(petId, updatedSettings);
  }

  // Mark tick & flea as done
  Future<void> markTickFleaAsDone(String petId) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    final updatedSettings = pet.tickFleaSettings!.copyWith(
      lastDate: DateTime.now(),
      snoozedUntil: null,
      updatedAt: DateTime.now(),
    );

    await updateTickFleaSettings(petId, updatedSettings);
  }

  // Snooze tick & flea for specified days
  Future<void> snoozeTickFlea(String petId, int days) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    final updatedSettings = pet.tickFleaSettings!.copyWith(
      snoozedUntil: DateTime.now().add(Duration(days: days)),
      updatedAt: DateTime.now(),
    );

    await updateTickFleaSettings(petId, updatedSettings);
  }
}
