import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

abstract class PetsEvent extends Equatable {
  const PetsEvent();

  @override
  List<Object?> get props => [];
}

class AddPet extends PetsEvent {
  final PetModel? petToEdit;

  const AddPet({this.petToEdit});

  @override
  List<Object?> get props => [petToEdit];
}

class AddVaccine extends PetsEvent {
  final VaccineModel vaccine;

  const AddVaccine({required this.vaccine});

  @override
  List<Object?> get props => [vaccine];
}

class LoadPets extends PetsEvent {
  const LoadPets();
}

class UpdatePet extends PetsEvent {
  final PetModel pet;

  const UpdatePet({required this.pet});

  @override
  List<Object?> get props => [pet];
}

class DeletePet extends PetsEvent {
  final String petId;

  const DeletePet({required this.petId});

  @override
  List<Object?> get props => [petId];
}

// Form Management Events
class UpdatePetFormField extends PetsEvent {
  final String field;
  final String value;

  const UpdatePetFormField({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

class UpdateVaccineFormField extends PetsEvent {
  final String field;
  final String value;

  const UpdateVaccineFormField({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

class SelectPetSpecies extends PetsEvent {
  final String species;

  const SelectPetSpecies({required this.species});

  @override
  List<Object?> get props => [species];
}

class SelectPetGender extends PetsEvent {
  final String gender;

  const SelectPetGender({required this.gender});

  @override
  List<Object?> get props => [gender];
}

class SelectPetDateOfBirth extends PetsEvent {
  final DateTime date;

  const SelectPetDateOfBirth({required this.date});

  @override
  List<Object?> get props => [date];
}

class SelectVaccineDateGiven extends PetsEvent {
  final DateTime date;

  const SelectVaccineDateGiven({required this.date});

  @override
  List<Object?> get props => [date];
}

class SelectVaccineNextDueDate extends PetsEvent {
  final DateTime date;

  const SelectVaccineNextDueDate({required this.date});

  @override
  List<Object?> get props => [date];
}

class ToggleVaccineReminder extends PetsEvent {
  final bool enabled;

  const ToggleVaccineReminder({required this.enabled});

  @override
  List<Object?> get props => [enabled];
}

class SelectPetImage extends PetsEvent {
  final String? imagePath;

  const SelectPetImage({this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class ValidatePetForm extends PetsEvent {
  const ValidatePetForm();
}

class ValidateVaccineForm extends PetsEvent {
  const ValidateVaccineForm();
}

class ResetPetForm extends PetsEvent {
  const ResetPetForm();
}

class ResetVaccineForm extends PetsEvent {
  const ResetVaccineForm();
}

// Pet Form Vaccine Management Events
class AddVaccineToPetForm extends PetsEvent {
  final VaccineModel vaccine;

  const AddVaccineToPetForm({required this.vaccine});

  @override
  List<Object?> get props => [vaccine];
}

class RemoveVaccineFromPetForm extends PetsEvent {
  final String vaccineId;

  const RemoveVaccineFromPetForm({required this.vaccineId});

  @override
  List<Object?> get props => [vaccineId];
}
