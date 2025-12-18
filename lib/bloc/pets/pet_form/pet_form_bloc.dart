import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_event.dart';
import 'package:paw_around/bloc/pets/pet_form/pet_form_state.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/storage_service.dart';

class PetFormBloc extends Bloc<PetFormEvent, PetFormState> {
  final PetRepository _petRepository;

  PetFormBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const PetFormState()) {
    // Form field updates
    on<UpdateName>(_onUpdateName);
    on<UpdateBreed>(_onUpdateBreed);
    on<UpdateWeight>(_onUpdateWeight);
    on<UpdateNotes>(_onUpdateNotes);
    on<SelectSpecies>(_onSelectSpecies);
    on<SelectGender>(_onSelectGender);
    on<SelectDateOfBirth>(_onSelectDateOfBirth);
    on<SelectImage>(_onSelectImage);

    // Vaccine management
    on<AddVaccine>(_onAddVaccine);
    on<RemoveVaccine>(_onRemoveVaccine);

    // Form actions
    on<InitializeForm>(_onInitializeForm);
    on<ValidateForm>(_onValidateForm);
    on<SubmitForm>(_onSubmitForm);
    on<ResetForm>(_onResetForm);
  }

  void _onUpdateName(UpdateName event, Emitter<PetFormState> emit) {
    emit(state.copyWith(name: event.name, status: PetFormStatus.editing));
  }

  void _onUpdateBreed(UpdateBreed event, Emitter<PetFormState> emit) {
    emit(state.copyWith(breed: event.breed, status: PetFormStatus.editing));
  }

  void _onUpdateWeight(UpdateWeight event, Emitter<PetFormState> emit) {
    emit(state.copyWith(weight: event.weight, status: PetFormStatus.editing));
  }

  void _onUpdateNotes(UpdateNotes event, Emitter<PetFormState> emit) {
    emit(state.copyWith(notes: event.notes, status: PetFormStatus.editing));
  }

  void _onSelectSpecies(SelectSpecies event, Emitter<PetFormState> emit) {
    emit(state.copyWith(species: event.species, status: PetFormStatus.editing));
  }

  void _onSelectGender(SelectGender event, Emitter<PetFormState> emit) {
    emit(state.copyWith(gender: event.gender, status: PetFormStatus.editing));
  }

  void _onSelectDateOfBirth(SelectDateOfBirth event, Emitter<PetFormState> emit) {
    emit(state.copyWith(dateOfBirth: event.date, status: PetFormStatus.editing));
  }

  void _onSelectImage(SelectImage event, Emitter<PetFormState> emit) {
    emit(state.copyWith(imagePath: event.imagePath, status: PetFormStatus.editing));
  }

  void _onAddVaccine(AddVaccine event, Emitter<PetFormState> emit) {
    final updatedVaccines = List<VaccineModel>.from(state.vaccines)..add(event.vaccine);
    emit(state.copyWith(vaccines: updatedVaccines, status: PetFormStatus.editing));
  }

  void _onRemoveVaccine(RemoveVaccine event, Emitter<PetFormState> emit) {
    final updatedVaccines = state.vaccines.where((v) => v.id != event.vaccineId).toList();
    emit(state.copyWith(vaccines: updatedVaccines, status: PetFormStatus.editing));
  }

  void _onInitializeForm(InitializeForm event, Emitter<PetFormState> emit) {
    if (event.petToEdit != null) {
      final pet = event.petToEdit!;
      emit(PetFormState(
        name: pet.name,
        species: pet.species,
        breed: pet.breed,
        gender: pet.gender,
        dateOfBirth: pet.dateOfBirth,
        weight: pet.weight.toString(),
        notes: pet.notes,
        imagePath: pet.imagePath,
        vaccines: pet.vaccines,
        status: PetFormStatus.editing,
      ));
    } else {
      emit(const PetFormState(status: PetFormStatus.initial));
    }
  }

  void _onValidateForm(ValidateForm event, Emitter<PetFormState> emit) {
    final errors = <String, String>{};

    if (state.name.isEmpty) {
      errors['name'] = 'Pet name is required';
    }
    if (state.species.isEmpty) {
      errors['species'] = 'Pet type is required';
    }
    if (state.gender.isEmpty) {
      errors['gender'] = 'Gender is required';
    }
    if (state.dateOfBirth == null) {
      errors['dateOfBirth'] = 'Age or birthdate is required';
    }

    final isValid = errors.isEmpty;
    emit(state.copyWith(errors: errors, isValid: isValid));
  }

  Future<void> _onSubmitForm(SubmitForm event, Emitter<PetFormState> emit) async {
    // Validate first
    add(const ValidateForm());

    // Wait for validation to complete
    await Future.delayed(const Duration(milliseconds: 50));

    if (!state.isValid) {
      return;
    }

    emit(state.copyWith(status: PetFormStatus.saving));

    try {
      final storageService = sl<StorageService>();
      String? imagePath;

      final existingPet = event.petToEdit;

      if (existingPet != null) {
        // Editing existing pet
        if (state.imagePath != null &&
            state.imagePath != existingPet.imagePath &&
            !state.imagePath!.startsWith('http')) {
          imagePath = await storageService.uploadPetImage(
            localPath: state.imagePath!,
            petId: existingPet.id,
          );
          if (imagePath == null) {
            emit(state.copyWith(
              status: PetFormStatus.error,
              errorMessage: 'Failed to upload pet image',
            ));
            return;
          }
        } else {
          imagePath = state.imagePath ?? existingPet.imagePath;
        }

        final updatedPet = existingPet.copyWith(
          name: state.name,
          species: state.species,
          breed: state.breed.isNotEmpty ? state.breed : existingPet.breed,
          gender: state.gender,
          dateOfBirth: state.dateOfBirth!,
          weight: state.weight.isNotEmpty ? double.tryParse(state.weight) ?? existingPet.weight : existingPet.weight,
          notes: state.notes,
          imagePath: imagePath,
          vaccines: state.vaccines,
          updatedAt: DateTime.now(),
        );

        await _petRepository.updatePet(updatedPet);
        emit(state.copyWith(status: PetFormStatus.success, savedPet: updatedPet));
      } else {
        // Adding new pet
        final tempPetId = DateTime.now().millisecondsSinceEpoch.toString();

        if (state.imagePath != null && !state.imagePath!.startsWith('http')) {
          imagePath = await storageService.uploadPetImage(
            localPath: state.imagePath!,
            petId: tempPetId,
          );
          if (imagePath == null) {
            emit(state.copyWith(
              status: PetFormStatus.error,
              errorMessage: 'Failed to upload pet image',
            ));
            return;
          }
        }

        final pet = PetModel.create(
          name: state.name,
          species: state.species,
          breed: state.breed.isNotEmpty ? state.breed : '',
          gender: state.gender,
          dateOfBirth: state.dateOfBirth!,
          weight: state.weight.isNotEmpty ? double.tryParse(state.weight) ?? 0.0 : 0.0,
          notes: state.notes,
          imagePath: imagePath,
          vaccines: state.vaccines,
        );

        final docId = await _petRepository.addPet(pet);
        final savedPet = pet.copyWith(id: docId);
        emit(state.copyWith(status: PetFormStatus.success, savedPet: savedPet));
      }
    } catch (e) {
      emit(state.copyWith(
        status: PetFormStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onResetForm(ResetForm event, Emitter<PetFormState> emit) {
    emit(const PetFormState());
  }
}
