import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

abstract class PetsState extends Equatable {
  const PetsState();

  @override
  List<Object?> get props => [];
}

class PetsInitial extends PetsState {
  const PetsInitial();
}

class PetsLoading extends PetsState {
  const PetsLoading();
}

class PetsLoaded extends PetsState {
  final List<PetModel> pets;

  const PetsLoaded({required this.pets});

  @override
  List<Object?> get props => [pets];
}

class PetsError extends PetsState {
  final String message;

  const PetsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PetAdded extends PetsState {
  final PetModel pet;

  const PetAdded({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class PetUpdated extends PetsState {
  final PetModel pet;

  const PetUpdated({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class PetDeleted extends PetsState {
  final String petId;

  const PetDeleted({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class VaccineAdded extends PetsState {
  final VaccineModel vaccine;

  const VaccineAdded({required this.vaccine});

  @override
  List<Object?> get props => [vaccine];
}

// Form States
class PetFormState extends PetsState {
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
      ];
}

class VaccineFormState extends PetsState {
  final String vaccineName;
  final DateTime? dateGiven;
  final DateTime? nextDueDate;
  final String notes;
  final bool setReminder;
  final Map<String, String> errors;
  final bool isValid;

  const VaccineFormState({
    this.vaccineName = '',
    this.dateGiven,
    this.nextDueDate,
    this.notes = '',
    this.setReminder = false,
    this.errors = const {},
    this.isValid = false,
  });

  VaccineFormState copyWith({
    String? vaccineName,
    DateTime? dateGiven,
    DateTime? nextDueDate,
    String? notes,
    bool? setReminder,
    Map<String, String>? errors,
    bool? isValid,
  }) {
    return VaccineFormState(
      vaccineName: vaccineName ?? this.vaccineName,
      dateGiven: dateGiven ?? this.dateGiven,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      notes: notes ?? this.notes,
      setReminder: setReminder ?? this.setReminder,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
        vaccineName,
        dateGiven,
        nextDueDate,
        notes,
        setReminder,
        errors,
        isValid,
      ];
}
