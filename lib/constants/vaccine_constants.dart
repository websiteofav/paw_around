import 'package:paw_around/models/vaccines/vaccine_master_data.dart';

/// Predefined vaccine data for pets
/// Users can only select from this list - no custom vaccines allowed
class VaccineConstants {
  VaccineConstants._();

  static List<String> allVaccines = dogVaccines.map((v) => v.name).toList() + catVaccines.map((v) => v.name).toList();

  /// Predefined dog vaccines
  static const List<VaccineMasterData> dogVaccines = [
    VaccineMasterData(
      id: 'rabies',
      name: 'Rabies',
      petType: 'dog',
      category: 'mandatory',
      frequencyMonths: 12,
      why: 'Rabies is a fatal viral disease and vaccination is required by law in many places.',
      whatToDo: 'Get the rabies vaccine administered by a licensed veterinarian.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'dhpp',
      name: 'DHPP',
      petType: 'dog',
      category: 'core',
      frequencyMonths: 12,
      why: 'Protects dogs from distemper, hepatitis, parvovirus, and parainfluenza.',
      whatToDo: 'Schedule the core DHPP vaccination with a veterinarian.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'bordetella',
      name: 'Bordetella',
      petType: 'dog',
      category: 'recommended',
      frequencyMonths: 12,
      why: 'Protects against kennel cough, a highly contagious respiratory disease.',
      whatToDo: 'Recommended for dogs that visit dog parks, groomers, or boarding facilities.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'leptospirosis',
      name: 'Leptospirosis',
      petType: 'dog',
      category: 'recommended',
      frequencyMonths: 12,
      why: 'Protects against a bacterial infection that can affect kidneys and liver.',
      whatToDo: 'Recommended for dogs exposed to wildlife or standing water.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'lyme',
      name: 'Lyme Disease',
      petType: 'dog',
      category: 'optional',
      frequencyMonths: 12,
      why: 'Protects against Lyme disease transmitted by ticks.',
      whatToDo: 'Recommended for dogs in tick-prone areas.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'canine_influenza',
      name: 'Canine Influenza',
      petType: 'dog',
      category: 'optional',
      frequencyMonths: 12,
      why: 'Protects against dog flu, a contagious respiratory infection.',
      whatToDo: 'Recommended for dogs that socialize frequently with other dogs.',
      ctaType: 'find_vets',
    ),
  ];

  /// Predefined cat vaccines
  static const List<VaccineMasterData> catVaccines = [
    VaccineMasterData(
      id: 'rabies',
      name: 'Rabies',
      petType: 'cat',
      category: 'mandatory',
      frequencyMonths: 12,
      why: 'Rabies is a fatal disease and vaccination is required by law in many places.',
      whatToDo: 'Get the rabies vaccine administered by a licensed veterinarian.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'fvrcp',
      name: 'FVRCP',
      petType: 'cat',
      category: 'core',
      frequencyMonths: 12,
      why: 'Protects cats from feline viral rhinotracheitis, calicivirus, and panleukopenia.',
      whatToDo: 'Get the core FVRCP vaccine from a veterinarian.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'felv',
      name: 'FeLV',
      petType: 'cat',
      category: 'recommended',
      frequencyMonths: 12,
      why: 'Protects against feline leukemia virus, which can cause cancer and immune deficiency.',
      whatToDo: 'Recommended for cats that go outdoors or live with FeLV-positive cats.',
      ctaType: 'find_vets',
    ),
    VaccineMasterData(
      id: 'fiv',
      name: 'FIV',
      petType: 'cat',
      category: 'optional',
      frequencyMonths: 12,
      why: 'Protects against feline immunodeficiency virus, which weakens the immune system.',
      whatToDo: 'Recommended for cats at high risk of exposure to infected cats.',
      ctaType: 'find_vets',
    ),
  ];

  /// Get vaccines by pet type
  /// Returns empty list for unsupported pet types (e.g. "Other")
  static List<VaccineMasterData> getVaccinesByPetType(String petType) {
    switch (petType.toLowerCase()) {
      case 'dog':
        return dogVaccines;
      case 'cat':
        return catVaccines;
      default:
        return [];
    }
  }

  /// Check if pet type supports vaccines
  static bool supportsVaccines(String petType) {
    final type = petType.toLowerCase();
    return type == 'dog' || type == 'cat';
  }

  /// Get vaccine master data by ID and pet type
  static VaccineMasterData? getVaccineById(String id, String petType) {
    final vaccines = getVaccinesByPetType(petType);
    try {
      return vaccines.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Legacy: Common vaccine names for dogs (for backward compatibility)
  static const List<String> dogVaccineNames = [
    'Rabies',
    'DHPP (Distemper, Hepatitis, Parvovirus, Parainfluenza)',
    'Bordetella (Kennel Cough)',
    'Lyme Disease',
    'Leptospirosis',
    'Canine Influenza',
  ];

  /// Legacy: Common vaccine names for cats (for backward compatibility)
  static const List<String> catVaccineNames = [
    'Rabies',
    'FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia)',
    'FeLV (Feline Leukemia)',
    'FIV (Feline Immunodeficiency Virus)',
  ];

  /// Legacy: Get vaccines by species (for backward compatibility)
  static List<String> getVaccinesBySpecies(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return dogVaccineNames;
      case 'cat':
        return catVaccineNames;
      default:
        return [...dogVaccineNames, ...catVaccineNames];
    }
  }
}
