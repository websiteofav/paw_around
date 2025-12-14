import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';

abstract class PetFormEvent extends Equatable {
  const PetFormEvent();

  @override
  List<Object?> get props => [];
}

// Form field updates
class UpdateName extends PetFormEvent {
  final String name;
  const UpdateName(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateBreed extends PetFormEvent {
  final String breed;
  const UpdateBreed(this.breed);

  @override
  List<Object?> get props => [breed];
}

class UpdateWeight extends PetFormEvent {
  final String weight;
  const UpdateWeight(this.weight);

  @override
  List<Object?> get props => [weight];
}

class UpdateNotes extends PetFormEvent {
  final String notes;
  const UpdateNotes(this.notes);

  @override
  List<Object?> get props => [notes];
}

class SelectSpecies extends PetFormEvent {
  final String species;
  const SelectSpecies(this.species);

  @override
  List<Object?> get props => [species];
}

class SelectGender extends PetFormEvent {
  final String gender;
  const SelectGender(this.gender);

  @override
  List<Object?> get props => [gender];
}

class SelectDateOfBirth extends PetFormEvent {
  final DateTime date;
  const SelectDateOfBirth(this.date);

  @override
  List<Object?> get props => [date];
}

class SelectImage extends PetFormEvent {
  final String? imagePath;
  const SelectImage(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}

// Vaccine management
class AddVaccine extends PetFormEvent {
  final VaccineModel vaccine;
  const AddVaccine(this.vaccine);

  @override
  List<Object?> get props => [vaccine];
}

class RemoveVaccine extends PetFormEvent {
  final String vaccineId;
  const RemoveVaccine(this.vaccineId);

  @override
  List<Object?> get props => [vaccineId];
}

// Form actions
class InitializeForm extends PetFormEvent {
  final PetModel? petToEdit;
  const InitializeForm({this.petToEdit});

  @override
  List<Object?> get props => [petToEdit];
}

class ValidateForm extends PetFormEvent {
  const ValidateForm();
}

class SubmitForm extends PetFormEvent {
  final PetModel? petToEdit;
  const SubmitForm({this.petToEdit});

  @override
  List<Object?> get props => [petToEdit];
}

class ResetForm extends PetFormEvent {
  const ResetForm();
}
