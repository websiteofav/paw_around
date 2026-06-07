import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
    final snapshot =
        await _petsRef.orderBy('createdAt', descending: true).get();
    final pets =
        snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();

    // Check for expired snoozes and reschedule notifications
    _rescheduleNotificationsForExpiredSnoozes(pets);

    return pets;
  }

  /// Reschedule notifications for items that are no longer snoozed
  /// This ensures notifications resume automatically after snooze periods end
  Future<void> _rescheduleNotificationsForExpiredSnoozes(
      List<PetModel> pets) async {
    final now = DateTime.now();
    final notificationService = NotificationService();

    for (final pet in pets) {
      // Check vaccines with expired snoozes
      for (final vaccine in pet.vaccines) {
        if (vaccine.setReminder &&
            vaccine.snoozedUntil != null &&
            vaccine.snoozedUntil!.isBefore(now)) {
          // Snooze expired - reschedule notifications
          try {
            await notificationService.scheduleVaccineReminder(
              petId: pet.id,
              petName: pet.name,
              vaccine: vaccine,
            );
          } catch (e) {
            debugPrint('Error rescheduling vaccine notifications: $e');
          }
        }
      }

      // Check grooming with expired snooze — reschedule any item whose snooze ended
      for (final settings in pet.groomingSettings) {
        if (settings.hasReminder &&
            settings.snoozedUntil != null &&
            settings.snoozedUntil!.isBefore(now)) {
          try {
            await notificationService.scheduleCareReminder(
              petId: pet.id,
              petName: pet.name,
              type: ReminderType.grooming,
              settings: settings,
            );
          } catch (e) {
            debugPrint('Error rescheduling grooming notifications: $e');
          }
        }
      }

      // Check tick/flea with expired snooze
      if (pet.tickFleaSettings != null) {
        final settings = pet.tickFleaSettings!;
        if (settings.hasReminder &&
            settings.snoozedUntil != null &&
            settings.snoozedUntil!.isBefore(now)) {
          // Snooze expired - reschedule notifications
          try {
            await notificationService.scheduleCareReminder(
              petId: pet.id,
              petName: pet.name,
              type: ReminderType.tickFlea,
              settings: settings,
            );
          } catch (e) {
            debugPrint('Error rescheduling tick/flea notifications: $e');
          }
        }
      }
    }
  }

  // Get pets stream for real-time updates
  Stream<List<PetModel>> getPetsStream() {
    return _petsRef.orderBy('createdAt', descending: true).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList(),
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
    // Check if pet name changed by fetching old pet
    final oldPet = await getPetById(pet.id);
    final nameChanged = oldPet != null && oldPet.name != pet.name;

    await _petsRef.doc(pet.id).update(pet.toFirestore());

    // Reschedule notifications if pet name changed
    if (nameChanged) {
      final updatedPet = await getPetById(pet.id);
      if (updatedPet != null) {
        // Reschedule grooming reminders (one per grooming type item)
        await NotificationService().cancelCareReminder(
          petId: updatedPet.id,
          type: ReminderType.grooming,
        );
        for (final s in updatedPet.groomingSettings) {
          if (s.hasReminder) {
            await NotificationService().scheduleCareReminder(
              petId: updatedPet.id,
              petName: updatedPet.name,
              type: ReminderType.grooming,
              settings: s,
            );
          }
        }

        // Reschedule tick & flea reminder
        final tickFlea = updatedPet.tickFleaSettings;
        if (tickFlea != null && tickFlea.hasReminder) {
          await NotificationService().cancelCareReminder(
            petId: updatedPet.id,
            type: ReminderType.tickFlea,
          );
          await NotificationService().scheduleCareReminder(
            petId: updatedPet.id,
            petName: updatedPet.name,
            type: ReminderType.tickFlea,
            settings: tickFlea,
          );
        }

        // Reschedule all vaccine reminders
        for (final vaccine in updatedPet.vaccines) {
          if (vaccine.setReminder) {
            // Cancel old notifications
            await NotificationService().cancelVaccineReminder(
              petId: updatedPet.id,
              vaccineId: vaccine.id,
            );

            // Reschedule with new name
            await NotificationService().scheduleVaccineReminder(
              petId: updatedPet.id,
              petName: updatedPet.name,
              vaccine: vaccine,
            );
          }
        }
      }
    }
  }

  // Delete pet
  Future<void> deletePet(String id, {StorageService? storageService}) async {
    final pet = await getPetById(id);
    if (pet != null) {
      // Cancel all notifications for this pet
      final vaccineIds = pet.vaccines.map((v) => v.id).toList();
      await NotificationService()
          .cancelAllRemindersForPetWithVaccines(id, vaccineIds);

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
        return (vaccine.nextDueDate?.isAfter(now) ?? false) &&
            (vaccine.nextDueDate?.isBefore(thirtyDaysFromNow) ?? false);
      });
    }).toList();
  }

  // Get pets with overdue vaccines
  Future<List<PetModel>> getPetsWithOverdueVaccines() async {
    final pets = await getAllPets();
    final now = DateTime.now();

    return pets.where((pet) {
      return pet.vaccines
          .any((vaccine) => vaccine.nextDueDate?.isBefore(now) ?? false);
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

  // Update (upsert) a single grooming settings entry into the pet's list.
  // Matches by groomingType; if not found, appends.
  Future<void> updateGroomingSettings(
      String petId, CareSettingsModel settings) async {
    final pet = await getPetById(petId);
    if (pet == null) return;

    final updated = List<CareSettingsModel>.from(pet.groomingSettings);
    final idx = updated.indexWhere((s) => s.groomingType == settings.groomingType);
    if (idx >= 0) {
      updated[idx] = settings;
    } else {
      updated.add(settings);
    }

    await _petsRef.doc(petId).update({
      'groomingSettings': updated.map((s) => s.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Update tick & flea settings for a pet
  Future<void> updateTickFleaSettings(
      String petId, CareSettingsModel settings) async {
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

    VaccineModel? oldVaccine;
    bool isUpdate = false;

    if (existingIndex >= 0) {
      // Update existing vaccine
      oldVaccine = updatedVaccines[existingIndex];
      isUpdate = true;
      updatedVaccines[existingIndex] = vaccine;
    } else {
      // Add new vaccine
      updatedVaccines.add(vaccine);
    }

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });

    // Reschedule notifications if vaccine was updated and name or reminder settings changed
    if (isUpdate && oldVaccine != null) {
      final nameChanged = oldVaccine.vaccineName != vaccine.vaccineName;
      final reminderChanged = oldVaccine.setReminder != vaccine.setReminder;
      final dueDateChanged = oldVaccine.nextDueDate != vaccine.nextDueDate;

      if (nameChanged || reminderChanged || dueDateChanged) {
        final updatedPet = await getPetById(petId);
        if (updatedPet != null) {
          final updatedVaccine = updatedPet.vaccines.firstWhere(
            (v) => v.id == vaccine.id,
            orElse: () => updatedPet.vaccines.firstWhere(
              (v) =>
                  v.vaccineName.toLowerCase() ==
                  vaccine.vaccineName.toLowerCase(),
            ),
          );

          // Cancel old notifications
          await NotificationService().cancelVaccineReminder(
            petId: updatedPet.id,
            vaccineId: updatedVaccine.id,
          );

          // Reschedule if reminder is enabled
          if (updatedVaccine.setReminder) {
            await NotificationService().scheduleVaccineReminder(
              petId: updatedPet.id,
              petName: updatedPet.name,
              vaccine: updatedVaccine,
            );
          }
        }
      }
    } else if (!isUpdate && vaccine.setReminder) {
      // New vaccine with reminder enabled - schedule notifications
      final updatedPet = await getPetById(petId);
      if (updatedPet != null) {
        final newVaccine = updatedPet.vaccines.firstWhere(
          (v) =>
              v.vaccineName.toLowerCase() == vaccine.vaccineName.toLowerCase(),
        );
        await NotificationService().scheduleVaccineReminder(
          petId: updatedPet.id,
          petName: updatedPet.name,
          vaccine: newVaccine,
        );
      }
    }
  }

  // Get pets with upcoming grooming (due within 7 days)
  Future<List<PetModel>> getPetsWithUpcomingGrooming() async {
    final pets = await getAllPets();
    return pets.where((pet) {
      return pet.groomingSettings.any((s) => s.isDueSoon || s.isOverdue);
    }).toList();
  }

  // Get pets with upcoming tick/flea treatment (due within 7 days)
  Future<List<PetModel>> getPetsWithUpcomingTickFlea() async {
    final pets = await getAllPets();
    return pets.where((pet) {
      return pet.tickFleaSettings?.isDueSoon == true ||
          pet.tickFleaSettings?.isOverdue == true;
    }).toList();
  }

  // Mark vaccine as done - updates dateGiven and recalculates nextDueDate
  Future<void> markVaccineAsDone(String petId, String vaccineId,
      {DateTime? completionDate}) async {
    final pet = await getPetById(petId);
    if (pet == null) {
      return;
    }

    final completion = completionDate ?? DateTime.now();

    final updatedVaccines = pet.vaccines.map((v) {
      if (v.id == vaccineId) {
        // Get existing history and deduplicate same-day entries
        final history = List<DateTime>.from(v.completionHistory);

        // Get the current latest completion (before adding new one) to calculate interval
        final currentLatest = history.isNotEmpty
            ? history.reduce((a, b) => a.isAfter(b) ? a : b)
            : v.dateGiven;

        // Remove any entry on the same day (deduplication)
        history.removeWhere((d) =>
            d.year == completion.year &&
            d.month == completion.month &&
            d.day == completion.day);

        // Add new completion date
        history.add(completion);

        // Sort descending (most recent first)
        history.sort((a, b) => b.compareTo(a));

        // Get the latest completion date (first item after sorting)
        final latestCompletion = history.isNotEmpty ? history[0] : completion;

        // Calculate original interval from stored nextDueDate and current latest completion
        // This preserves the interval that was set based on the previous completion
        final originalInterval = v.nextDueDate != null
            ? v.nextDueDate!.difference(currentLatest).inDays
            : 0;

        // Calculate nextDueDate from the latest completion date
        final calculatedNextDueDate = v.nextDueDate != null
            ? latestCompletion.add(
                Duration(days: originalInterval > 0 ? originalInterval : 365))
            : null;

        return v.copyWith(
          dateGiven: latestCompletion, // Update to latest completion
          nextDueDate: calculatedNextDueDate, // Calculate from latest
          clearSnoozedUntil: true,
          updatedAt: DateTime.now(),
          completionHistory: history,
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

    // Find the vaccine to get its nextDueDate
    final vaccine = pet.vaccines.firstWhere(
      (v) => v.id == vaccineId,
      orElse: () => pet.vaccines.first,
    );

    // Cancel existing notifications
    await NotificationService().cancelVaccineReminder(
      petId: petId,
      vaccineId: vaccineId,
    );

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

    // Reschedule notifications if reminder is enabled
    // The scheduling logic will automatically skip past dates
    if (vaccine.setReminder && vaccine.nextDueDate != null) {
      // Fetch updated pet to get the snoozed vaccine
      final updatedPet = await getPetById(petId);
      if (updatedPet != null) {
        final updatedVaccine = updatedPet.vaccines.firstWhere(
          (v) => v.id == vaccineId,
          orElse: () => updatedPet.vaccines.first,
        );
        await NotificationService().scheduleVaccineReminder(
          petId: updatedPet.id,
          petName: updatedPet.name,
          vaccine: updatedVaccine,
        );
      }
    }
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

    // Reschedule notifications after unsnoozing
    final updatedPet = await getPetById(petId);
    if (updatedPet != null) {
      final updatedVaccine = updatedPet.vaccines.firstWhere(
        (v) => v.id == vaccineId,
        orElse: () => updatedPet.vaccines.first,
      );

      if (updatedVaccine.setReminder) {
        await NotificationService().scheduleVaccineReminder(
          petId: updatedPet.id,
          petName: updatedPet.name,
          vaccine: updatedVaccine,
        );
      }
    }
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

    final updatedVaccines =
        pet.vaccines.where((v) => v.id != vaccineId).toList();

    await _petsRef.doc(petId).update({
      'vaccines': updatedVaccines.map((v) => v.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Mark grooming as done.
  // If groomingType is provided, only updates that specific item.
  // If null, updates all items in the list.
  Future<void> markGroomingAsDone(String petId,
      {DateTime? completionDate, String? groomingType}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings.isEmpty) return;

    final completion = completionDate ?? DateTime.now();

    final updatedList = pet.groomingSettings.map((s) {
      if (groomingType != null && s.groomingType != groomingType) return s;

      final history = List<DateTime>.from(s.completionHistory);
      history.removeWhere((d) =>
          d.year == completion.year &&
          d.month == completion.month &&
          d.day == completion.day);
      history.add(completion);
      history.sort((a, b) => b.compareTo(a));
      final latest = history.isNotEmpty ? history[0] : completion;

      return s.copyWith(
        lastDate: latest,
        completionHistory: history,
        clearSnoozedUntil: true,
        updatedAt: DateTime.now(),
      );
    }).toList();

    await _petsRef.doc(petId).update({
      'groomingSettings': updatedList.map((s) => s.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });
  }

  // Unsnooze grooming reminder (all items).
  Future<void> unsnoozeGrooming(String petId, {String? groomingType}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings.isEmpty) return;

    final updatedList = pet.groomingSettings.map((s) {
      if (groomingType != null && s.groomingType != groomingType) return s;
      return s.copyWith(clearSnoozedUntil: true, updatedAt: DateTime.now());
    }).toList();

    await _petsRef.doc(petId).update({
      'groomingSettings': updatedList.map((s) => s.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });

    // Reschedule notifications after unsnoozing
    final updatedPet = await getPetById(petId);
    if (updatedPet != null) {
      for (final s in updatedPet.groomingSettings) {
        if (s.hasReminder) {
          await NotificationService().scheduleCareReminder(
            petId: updatedPet.id,
            petName: updatedPet.name,
            type: ReminderType.grooming,
            settings: s,
          );
        }
      }
    }
  }

  // Snooze grooming for specified days.
  // If groomingType is provided, only snoozes that specific item.
  Future<void> snoozeGrooming(String petId, int days,
      {String? groomingType}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.groomingSettings.isEmpty) return;

    // Cancel existing grooming notifications
    await NotificationService().cancelCareReminder(
      petId: petId,
      type: ReminderType.grooming,
    );

    final snoozedUntil = DateTime.now().add(Duration(days: days));
    final updatedList = pet.groomingSettings.map((s) {
      if (groomingType != null && s.groomingType != groomingType) return s;
      return s.copyWith(snoozedUntil: snoozedUntil, updatedAt: DateTime.now());
    }).toList();

    await _petsRef.doc(petId).update({
      'groomingSettings': updatedList.map((s) => s.toFirestore()).toList(),
      'updatedAt': Timestamp.now(),
    });

    // Reschedule notifications for items that have a reminder and due date
    final updatedPet = await getPetById(petId);
    if (updatedPet != null) {
      for (final s in updatedPet.groomingSettings) {
        if (s.hasReminder && s.nextDueDate != null) {
          await NotificationService().scheduleCareReminder(
            petId: updatedPet.id,
            petName: updatedPet.name,
            type: ReminderType.grooming,
            settings: s,
          );
        }
      }
    }
  }

  // Mark tick & flea as done
  Future<void> markTickFleaAsDone(String petId,
      {DateTime? completionDate}) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    final completion = completionDate ?? DateTime.now();

    // Get existing history and deduplicate same-day entries
    final updatedHistory =
        List<DateTime>.from(pet.tickFleaSettings!.completionHistory);

    // Remove any entry on the same day (deduplication)
    updatedHistory.removeWhere((d) =>
        d.year == completion.year &&
        d.month == completion.month &&
        d.day == completion.day);

    // Add new completion date
    updatedHistory.add(completion);

    // Sort descending (most recent first)
    updatedHistory.sort((a, b) => b.compareTo(a));

    // Get the latest completion date (first item after sorting)
    final latestCompletion =
        updatedHistory.isNotEmpty ? updatedHistory[0] : completion;

    final updatedSettings = pet.tickFleaSettings!.copyWith(
      lastDate: latestCompletion, // Use latest from history
      completionHistory: updatedHistory,
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

    // Reschedule notifications after unsnoozing
    final updatedPet = await getPetById(petId);
    if (updatedPet != null && updatedPet.tickFleaSettings != null) {
      final settings = updatedPet.tickFleaSettings!;
      if (settings.hasReminder) {
        await NotificationService().scheduleCareReminder(
          petId: updatedPet.id,
          petName: updatedPet.name,
          type: ReminderType.tickFlea,
          settings: settings,
        );
      }
    }
  }

  // Snooze tick & flea for specified days
  Future<void> snoozeTickFlea(String petId, int days) async {
    final pet = await getPetById(petId);
    if (pet == null || pet.tickFleaSettings == null) {
      return;
    }

    // Cancel existing notifications
    await NotificationService().cancelCareReminder(
      petId: petId,
      type: ReminderType.tickFlea,
    );

    final snoozedUntil = DateTime.now().add(Duration(days: days));
    final updatedSettings = pet.tickFleaSettings!.copyWith(
      snoozedUntil: snoozedUntil,
      updatedAt: DateTime.now(),
    );

    await updateTickFleaSettings(petId, updatedSettings);

    // Reschedule notifications if reminder is enabled
    // The scheduling logic will automatically skip past dates
    if (updatedSettings.hasReminder && updatedSettings.nextDueDate != null) {
      final updatedPet = await getPetById(petId);
      if (updatedPet != null && updatedPet.tickFleaSettings != null) {
        await NotificationService().scheduleCareReminder(
          petId: updatedPet.id,
          petName: updatedPet.name,
          type: ReminderType.tickFlea,
          settings: updatedPet.tickFleaSettings!,
        );
      }
    }
  }

  /// Delete all pets for a specific user (used for account deletion)
  Future<void> deleteAllPetsForUser(String userId,
      {StorageService? storageService}) async {
    final petsRef =
        _firestore.collection('users').doc(userId).collection('pets');
    final snapshot = await petsRef.get();

    final notificationService = NotificationService();
    final storage = storageService ?? StorageService();

    // Cancel notifications and delete images for all pets
    for (final doc in snapshot.docs) {
      final petId = doc.id;
      final petData = doc.data();

      // Cancel notifications
      final vaccines = (petData['vaccines'] as List<dynamic>?) ?? [];
      final vaccineIds = vaccines
          .map((v) => (v as Map<String, dynamic>)['id'] as String)
          .toList();
      await notificationService.cancelAllRemindersForPetWithVaccines(
          petId, vaccineIds);

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
      final vaccinesSnapshot =
          await petsRef.doc(doc.id).collection('vaccines').get();
      for (final vaccineDoc in vaccinesSnapshot.docs) {
        batch.delete(vaccineDoc.reference);
      }
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
