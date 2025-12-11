import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:paw_around/models/pets/pet_model.dart';

class PetRepository {
  static const String _boxName = 'pets';
  late Box<PetModel> _box;

  PetRepository();

  Future<void> init() async {
    // Check if box is already open, if not open it
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<PetModel>(_boxName);
    } else {
      _box = await Hive.openBox<PetModel>(_boxName);
    }
  }

  // Get all pets
  List<PetModel> getAllPets() {
    return _box.values.toList();
  }

  // Get pet by ID
  PetModel? getPetById(String id) {
    return _box.get(id);
  }

  // Add pet
  Future<void> addPet(PetModel pet) async {
    await _box.put(pet.id, pet);
  }

  // Update pet
  Future<void> updatePet(PetModel pet) async {
    await _box.put(pet.id, pet);
  }

  // Delete pet
  Future<void> deletePet(String id) async {
    // Vaccines are stored with the pet, so deleting the pet removes them too
    await _box.delete(id);
  }

  // Get pets by species
  List<PetModel> getPetsBySpecies(String species) {
    return _box.values.where((pet) => pet.species == species).toList();
  }

  // Get pets with upcoming vaccines
  List<PetModel> getPetsWithUpcomingVaccines() {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    return _box.values.where((pet) {
      return pet.vaccines.any((vaccine) {
        return vaccine.nextDueDate.isAfter(now) && vaccine.nextDueDate.isBefore(thirtyDaysFromNow);
      });
    }).toList();
  }

  // Get pets with overdue vaccines
  List<PetModel> getPetsWithOverdueVaccines() {
    final now = DateTime.now();
    return _box.values.where((pet) {
      return pet.vaccines.any((vaccine) => vaccine.nextDueDate.isBefore(now));
    }).toList();
  }

  // Get pet count
  int getPetCount() {
    return _box.length;
  }

  // Clear all pets
  Future<void> clearAllPets() async {
    await _box.clear();
  }

  // Close the box
  Future<void> close() async {
    await _box.close();
  }
}
