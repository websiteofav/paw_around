import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

enum PetFormStatus {
  initial,
  editing,
  saving,
  success,
  error,
}

class PetFormState extends Equatable {
  final String name;
  final String species;
  final String breed;
  final String gender;
  final DateTime? dateOfBirth;
  final String weight;
  final String notes;
  final String? imagePath;
  final List<VaccineModel> vaccines;
  final Map<String, String> errors;
  final bool isValid;
  final PetFormStatus status;
  final String? errorMessage;
  final PetModel? savedPet;

  const PetFormState({
    this.name = '',
    this.species = 'Dog',
    this.breed = '',
    this.gender = 'Male',
    this.dateOfBirth,
    this.weight = '',
    this.notes = '',
    this.imagePath,
    this.vaccines = const [],
    this.errors = const {},
    this.isValid = false,
    this.status = PetFormStatus.initial,
    this.errorMessage,
    this.savedPet,
  });

  PetFormState copyWith({
    String? name,
    String? species,
    String? breed,
    String? gender,
    DateTime? dateOfBirth,
    String? weight,
    String? notes,
    String? imagePath,
    List<VaccineModel>? vaccines,
    Map<String, String>? errors,
    bool? isValid,
    PetFormStatus? status,
    String? errorMessage,
    PetModel? savedPet,
  }) {
    return PetFormState(
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      vaccines: vaccines ?? this.vaccines,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      savedPet: savedPet ?? this.savedPet,
    );
  }

  @override
  List<Object?> get props => [
        name,
        species,
        breed,
        gender,
        dateOfBirth,
        weight,
        notes,
        imagePath,
        vaccines,
        errors,
        isValid,
        status,
        errorMessage,
        savedPet,
      ];
}
