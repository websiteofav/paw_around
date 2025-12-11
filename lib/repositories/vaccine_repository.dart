import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

class VaccineRepository {
  static const String _boxName = 'vaccine_types';
  Box<VaccineModel>? _box;
  bool _isInitialized = false;

  Future<void> init() async {
    if (!_isInitialized) {
      // Check if box is already open, if not open it
      if (Hive.isBoxOpen(_boxName)) {
        _box = Hive.box<VaccineModel>(_boxName);
      } else {
        _box = await Hive.openBox<VaccineModel>(_boxName);
      }
      _isInitialized = true;

      // Initialize with common vaccine types if empty
      if (_box!.isEmpty) {
        await _initializeDefaultVaccines();
      }
    }
  }

  bool get isInitialized => _isInitialized;

  // Initialize with common vaccine types
  Future<void> _initializeDefaultVaccines() async {
    final defaultVaccines = [
      VaccineModel.create(
        vaccineName: 'Rabies',
        dateGiven: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 365)),
        notes: 'Annual rabies vaccination',
        setReminder: true,
      ),
      VaccineModel.create(
        vaccineName: 'DHPP',
        dateGiven: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 365)),
        notes: 'Distemper, Hepatitis, Parvovirus, Parainfluenza',
        setReminder: true,
      ),
      VaccineModel.create(
        vaccineName: 'Bordetella',
        dateGiven: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 180)),
        notes: 'Kennel cough prevention',
        setReminder: true,
      ),
      VaccineModel.create(
        vaccineName: 'Lyme Disease',
        dateGiven: DateTime.now(),
        nextDueDate: DateTime.now().add(const Duration(days: 365)),
        notes: 'Tick-borne disease prevention',
        setReminder: true,
      ),
    ];

    for (final vaccine in defaultVaccines) {
      await _box!.put(vaccine.id, vaccine);
    }
  }

  // Get all vaccine types (master list)
  List<VaccineModel> getAllVaccines() {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    return _box!.values.toList();
  }

  // Get unique vaccine names for dropdown
  List<String> getVaccineNames() {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    return _box!.values.map((v) => v.vaccineName).toSet().toList()..sort();
  }

  // Add new vaccine type to master list
  Future<void> addVaccine(VaccineModel vaccine) async {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    await _box!.put(vaccine.id, vaccine);
  }

  // Update vaccine type
  Future<void> updateVaccine(VaccineModel vaccine) async {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    await _box!.put(vaccine.id, vaccine);
  }

  // Delete vaccine type
  Future<void> deleteVaccine(String id) async {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    await _box!.delete(id);
  }

  // Clear all vaccine types
  Future<void> clearAllVaccines() async {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    await _box!.clear();
  }

  // Get vaccine type count
  int getVaccineCount() {
    if (!_isInitialized || _box == null) {
      throw Exception('VaccineRepository not initialized');
    }
    return _box!.length;
  }

  // Close the box
  Future<void> close() async {
    if (_box != null) {
      await _box!.close();
    }
  }
}
