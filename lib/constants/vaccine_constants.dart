/// Common vaccine names for pets
class VaccineConstants {
  VaccineConstants._();

  /// Common dog vaccines
  static const List<String> dogVaccines = [
    'Rabies',
    'DHPP (Distemper, Hepatitis, Parvovirus, Parainfluenza)',
    'Bordetella (Kennel Cough)',
    'Lyme Disease',
    'Leptospirosis',
    'Canine Influenza',
  ];

  /// Common cat vaccines
  static const List<String> catVaccines = [
    'Rabies',
    'FVRCP (Feline Viral Rhinotracheitis, Calicivirus, Panleukopenia)',
    'FeLV (Feline Leukemia)',
    'FIV (Feline Immunodeficiency Virus)',
  ];

  /// All common vaccines (combined and sorted)
  static List<String> get allVaccines {
    final combined = <String>{...dogVaccines, ...catVaccines};
    return combined.toList()..sort();
  }

  /// Get vaccines by species
  static List<String> getVaccinesBySpecies(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return dogVaccines;
      case 'cat':
        return catVaccines;
      default:
        return allVaccines;
    }
  }
}
