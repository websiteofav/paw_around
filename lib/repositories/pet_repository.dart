import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paw_around/models/pets/care_settings_model.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/notification_service.dart';
import 'package:paw_around/services/storage_service.dart';

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
  Future<void> deletePet(String id, {StorageService? storageService}) async {
    final pet = await getPetById(id);
    if (pet != null) {
      // Cancel all notifications for this pet
      final vaccineIds = pet.vaccines.map((v) => v.id).toList();
      await NotificationService().cancelAllRemindersForPetWithVaccines(id, vaccineIds);

      // Delete pet image from storage if exists
      if (pet.imagePath != null && pet.imagePath!.startsWith('http')) {
        final storage = storageService ?? StorageService();
        await storage.deleteImage(pet.imagePath!);
      }
    }

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
  Future<void> markVaccineAsDone(String petId, String vaccineId, {DateTime? completionDate}) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final completion = completionDate ?? DateTime.now();

    final updatedVaccines = pet.vaccines.map((v) {
      if (v.id == vaccineId) {
        // Calculate next due date based on original interval
        final originalInterval = v.nextDueDate.difference(v.dateGiven).inDays;
        return v.copyWith(
          dateGiven: completion,
          nextDueDate: completion.add(Duration(days: originalInterval > 0 ? originalInterval : 365)),
          clearSnoozedUntil: true,
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

  // Unsnooze vaccine reminder
  Future<void> unsnoozeVaccine(String petId, String vaccineId) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final updatedVaccines = pet.vaccines.map((v) {
      if (v.id == vaccineId) {
        return v.copyWith(
          clearSnoozedUntil: true,
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

  // Delete a vaccine from a pet
  Future<void> deleteVaccine(String petId, String vaccineId) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    // Cancel vaccine notifications
    await NotificationService().cancelVaccineReminder(
      petId: petId,
      vaccineId: vaccineId,
    );

    final updatedVaccines = pet.vaccines.where((v) => v.id != vaccineId).toList();

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Mark grooming as done
  Future<void> markGroomingAsDone(String petId, {DateTime? completionDate}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings == null) {
      return;
    }

    final completion = completionDate ?? DateTime.now();

    final updatedSettings = pet.groomingSettings!.copyWith(
      lastDate: completion,
      clearSnoozedUntil: true,
      updatedAt: DateTime.now(),
    );

    await updateGroomingSettings(petId, updatedSettings);
  }

  // Unsnooze grooming reminder
  Future<void> unsnoozeGrooming(String petId) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings == null) {
      return;
    }

    final updatedSettings = pet.groomingSettings!.copyWith(
      clearSnoozedUntil: true,
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
  Future<void> markTickFleaAsDone(String petId, {DateTime? completionDate}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    final completion = completionDate ?? DateTime.now();

    final updatedSettings = pet.tickFleaSettings!.copyWith(
      lastDate: completion,
      clearSnoozedUntil: true,
      updatedAt: DateTime.now(),
    );

    await updateTickFleaSettings(petId, updatedSettings);
  }

  // Unsnooze tick & flea reminder
  Future<void> unsnoozeTickFlea(String petId) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    final updatedSettings = pet.tickFleaSettings!.copyWith(
      clearSnoozedUntil: true,
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

  /// Delete all pets for a specific user (used for account deletion)
  Future<void> deleteAllPetsForUser(String userId, {StorageService? storageService}) async {
    final petsRef = _firestore.collection('users').doc(userId).collection('pets');
    final snapshot = await petsRef.get();

    final notificationService = NotificationService();
    final storage = storageService ?? StorageService();

    // Cancel notifications and delete images for all pets
    for (final doc in snapshot.docs) {
      final petId = doc.id;
      final petData = doc.data();

      // Cancel notifications
      final vaccines = (petData['vaccines'] as List<dynamic>?) ?? [];
      final vaccineIds = vaccines.map((v) => (v as Map<String, dynamic>)['id'] as String).toList();
      await notificationService.cancelAllRemindersForPetWithVaccines(petId, vaccineIds);

      // Delete pet image from storage
      final imagePath = petData['imagePath'] as String?;
      if (imagePath != null && imagePath.startsWith('http')) {
        await storage.deleteImage(imagePath);
      }
    }

    // Delete all pets in a batch
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      // Also delete vaccines subcollection for each pet
      final vaccinesSnapshot = await petsRef.doc(doc.id).collection('vaccines').get();
      for (final vaccineDoc in vaccinesSnapshot.docs) {
        batch.delete(vaccineDoc.reference);
      }
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
