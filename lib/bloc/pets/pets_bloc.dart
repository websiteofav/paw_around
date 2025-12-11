import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paw_around/bloc/pets/pets_event.dart';
import 'package:paw_around/bloc/pets/pets_state.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/upcoming_vaccine_model.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/vaccine_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/image_service.dart';

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final VaccineRepository _vaccineRepository;
  final PetRepository _petRepository;

  PetsBloc({
    required VaccineRepository vaccineRepository,
    required PetRepository petRepository,
  })  : _vaccineRepository = vaccineRepository,
        _petRepository = petRepository,
        super(const PetFormState()) {
    // Pet Management
    on<LoadPets>(_onLoadPets);
    on<AddPet>(_onAddPet);
    on<DeletePet>(_onDeletePet);

    // Pet Form Management
    on<UpdatePetFormField>(_onUpdatePetFormField);
    on<SelectPetSpecies>(_onSelectPetSpecies);
    on<SelectPetGender>(_onSelectPetGender);
    on<SelectPetDateOfBirth>(_onSelectPetDateOfBirth);
    on<SelectPetImage>(_onSelectPetImage);
    on<ValidatePetForm>(_onValidatePetForm);
    on<ResetPetForm>(_onResetPetForm);

    // Vaccine Form Management
    on<UpdateVaccineFormField>(_onUpdateVaccineFormField);
    on<SelectVaccineDateGiven>(_onSelectVaccineDateGiven);
    on<SelectVaccineNextDueDate>(_onSelectVaccineNextDueDate);
    on<ToggleVaccineReminder>(_onToggleVaccineReminder);
    on<ValidateVaccineForm>(_onValidateVaccineForm);
    on<ResetVaccineForm>(_onResetVaccineForm);

    // Pet Form Vaccine Management
    on<AddVaccineToPetForm>(_onAddVaccineToPetForm);
    on<RemoveVaccineFromPetForm>(_onRemoveVaccineFromPetForm);
  }

  void _onLoadPets(LoadPets event, Emitter<PetsState> emit) async {
    emit(const PetsLoading());

    try {
      final pets = _petRepository.getAllPets();
      emit(PetsLoaded(pets: pets));
    } catch (e) {
      emit(PetsError(message: e.toString()));
    }
  }

  void _onAddPet(AddPet event, Emitter<PetsState> emit) async {
    try {
      if (state is! PetFormState) {
        emit(const PetsError(message: 'No form data available'));
        return;
      }

      final formState = state as PetFormState;

      // Validate form first
      final errors = <String, String>{};

      if (formState.name.isEmpty) {
        errors['name'] = 'Pet name is required';
      }
      if (formState.species.isEmpty) {
        errors['species'] = 'Species is required';
      }
      if (formState.breed.isEmpty) {
        errors['breed'] = 'Breed is required';
      }
      if (formState.gender.isEmpty) {
        errors['gender'] = 'Gender is required';
      }
      if (formState.dateOfBirth == null) {
        errors['dateOfBirth'] = 'Date of birth is required';
      }
      if (formState.weight.isEmpty) {
        errors['weight'] = 'Weight is required';
      } else if (double.tryParse(formState.weight) == null) {
        errors['weight'] = 'Invalid weight';
      }

      // If validation fails, emit error state
      if (errors.isNotEmpty) {
        emit(formState.copyWith(errors: errors, isValid: false));
        return;
      }

      // Check if we're editing an existing pet
      final existingPet = event.petToEdit;

      String petId;
      String? imagePath;

      if (existingPet != null) {
        // Editing existing pet
        petId = existingPet.id;

        // Handle image update
        if (formState.imagePath != null && formState.imagePath != existingPet.imagePath) {
          // New image selected, save it
          imagePath = await ImageService.savePetImage(petId, XFile(formState.imagePath!));
          if (imagePath == null) {
            emit(PetsError(message: 'Failed to save pet image'));
            return;
          }
        } else {
          // Keep existing image
          imagePath = existingPet.imagePath;
        }

        // Create updated pet
        final updatedPet = existingPet.copyWith(
          name: formState.name,
          species: formState.species,
          breed: formState.breed,
          gender: formState.gender,
          dateOfBirth: formState.dateOfBirth!,
          weight: double.parse(formState.weight),
          notes: formState.notes,
          imagePath: imagePath,
          vaccines: formState.vaccines,
          updatedAt: DateTime.now(),
        );

        // Update pet in Hive
        await _petRepository.updatePet(updatedPet);
        emit(PetUpdated(pet: updatedPet));
      } else {
        // Adding new pet
        petId = DateTime.now().millisecondsSinceEpoch.toString();

        // Save image if one was selected
        if (formState.imagePath != null) {
          imagePath = await ImageService.savePetImage(petId, XFile(formState.imagePath!));
          if (imagePath == null) {
            emit(PetsError(message: 'Failed to save pet image'));
            return;
          }
        }

        // Create new pet
        final pet = PetModel.create(
          name: formState.name,
          species: formState.species,
          breed: formState.breed,
          gender: formState.gender,
          dateOfBirth: formState.dateOfBirth!,
          weight: double.parse(formState.weight),
          notes: formState.notes,
          imagePath: imagePath,
          vaccines: formState.vaccines,
        );

        // Save pet to Hive
        await _petRepository.addPet(pet);
        emit(PetAdded(pet: pet));
      }
    } catch (e) {
      emit(PetsError(message: e.toString()));
    }
  }

  void _onUpdatePet(UpdatePet event, Emitter<PetsState> emit) async {
    try {
      // TODO: Update pet in local storage or API

      emit(PetUpdated(pet: event.pet));
    } catch (e) {
      emit(PetsError(message: e.toString()));
    }
  }

  void _onDeletePet(DeletePet event, Emitter<PetsState> emit) async {
    try {
      await _petRepository.deletePet(event.petId);

      emit(PetDeleted(petId: event.petId));
    } catch (e) {
      emit(PetsError(message: e.toString()));
    }
  }

  // Pet Form Management
  void _onUpdatePetFormField(UpdatePetFormField event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      PetFormState newState;

      switch (event.field) {
        case 'name':
          newState = currentState.copyWith(name: event.value);
          break;
        case 'breed':
          newState = currentState.copyWith(breed: event.value);
          break;
        case 'weight':
          newState = currentState.copyWith(weight: event.value);
          break;
        case 'notes':
          newState = currentState.copyWith(notes: event.value);
          break;
        default:
          return;
      }

      emit(newState);
    }
  }

  void _onSelectPetSpecies(SelectPetSpecies event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      emit(currentState.copyWith(species: event.species));
    }
  }

  void _onSelectPetGender(SelectPetGender event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      emit(currentState.copyWith(gender: event.gender));
    }
  }

  void _onSelectPetDateOfBirth(SelectPetDateOfBirth event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      emit(currentState.copyWith(dateOfBirth: event.date));
    }
  }

  void _onSelectPetImage(SelectPetImage event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      emit(currentState.copyWith(imagePath: event.imagePath));
    }
  }

  void _onValidatePetForm(ValidatePetForm event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      final currentState = state as PetFormState;
      final errors = <String, String>{};

      if (currentState.name.isEmpty) {
        errors['name'] = 'Please enter pet name';
      }
      if (currentState.breed.isEmpty) {
        errors['breed'] = 'Please enter breed';
      }
      if (currentState.weight.isEmpty) {
        errors['weight'] = 'Please enter weight';
      } else if (double.tryParse(currentState.weight) == null) {
        errors['weight'] = 'Please enter a valid weight';
      }
      if (currentState.dateOfBirth == null) {
        errors['dateOfBirth'] = 'Please select date of birth';
      }

      final isValid = errors.isEmpty;
      emit(currentState.copyWith(errors: errors, isValid: isValid));
    }
  }

  void _onResetPetForm(ResetPetForm event, Emitter<PetsState> emit) {
    emit(const PetFormState());
  }

  // Vaccine Form Management
  void _onUpdateVaccineFormField(UpdateVaccineFormField event, Emitter<PetsState> emit) {
    if (state is VaccineFormState) {
      final currentState = state as VaccineFormState;
      VaccineFormState newState;

      switch (event.field) {
        case 'vaccineName':
          newState = currentState.copyWith(vaccineName: event.value);
          break;
        case 'notes':
          newState = currentState.copyWith(notes: event.value);
          break;
        default:
          return;
      }

      // Validate form after field update
      final errors = <String, String>{};
      if (newState.vaccineName.isEmpty) {
        errors['vaccineName'] = 'Please enter vaccine name';
      }
      if (newState.dateGiven == null) {
        errors['dateGiven'] = 'Please select date given';
      }
      if (newState.nextDueDate == null) {
        errors['nextDueDate'] = 'Please select next due date';
      }

      final isValid = errors.isEmpty;
      emit(newState.copyWith(errors: errors, isValid: isValid));
    }
  }

  void _onSelectVaccineDateGiven(SelectVaccineDateGiven event, Emitter<PetsState> emit) {
    if (state is VaccineFormState) {
      final currentState = state as VaccineFormState;
      final newState = currentState.copyWith(dateGiven: event.date);

      // Validate form after date selection
      final errors = <String, String>{};
      if (newState.vaccineName.isEmpty) {
        errors['vaccineName'] = 'Please enter vaccine name';
      }
      if (newState.dateGiven == null) {
        errors['dateGiven'] = 'Please select date given';
      }
      if (newState.nextDueDate == null) {
        errors['nextDueDate'] = 'Please select next due date';
      }

      final isValid = errors.isEmpty;
      emit(newState.copyWith(errors: errors, isValid: isValid));
    }
  }

  void _onSelectVaccineNextDueDate(SelectVaccineNextDueDate event, Emitter<PetsState> emit) {
    if (state is VaccineFormState) {
      final currentState = state as VaccineFormState;
      final newState = currentState.copyWith(nextDueDate: event.date);

      // Validate form after date selection
      final errors = <String, String>{};
      if (newState.vaccineName.isEmpty) {
        errors['vaccineName'] = 'Please enter vaccine name';
      }
      if (newState.dateGiven == null) {
        errors['dateGiven'] = 'Please select date given';
      }
      if (newState.nextDueDate == null) {
        errors['nextDueDate'] = 'Please select next due date';
      }

      final isValid = errors.isEmpty;
      emit(newState.copyWith(errors: errors, isValid: isValid));
    }
  }

  void _onToggleVaccineReminder(ToggleVaccineReminder event, Emitter<PetsState> emit) {
    if (state is VaccineFormState) {
      final currentState = state as VaccineFormState;
      emit(currentState.copyWith(setReminder: event.enabled));
    }
  }

  void _onValidateVaccineForm(ValidateVaccineForm event, Emitter<PetsState> emit) {
    if (state is VaccineFormState) {
      final currentState = state as VaccineFormState;
      final errors = <String, String>{};

      if (currentState.vaccineName.isEmpty) {
        errors['vaccineName'] = 'Please enter vaccine name';
      }
      if (currentState.dateGiven == null) {
        errors['dateGiven'] = 'Please select date given';
      }
      if (currentState.nextDueDate == null) {
        errors['nextDueDate'] = 'Please select next due date';
      }

      final isValid = errors.isEmpty;
      emit(currentState.copyWith(errors: errors, isValid: isValid));
    }
  }

  void _onResetVaccineForm(ResetVaccineForm event, Emitter<PetsState> emit) {
    emit(const VaccineFormState());
  }

  // Pet Form Vaccine Management
  void _onAddVaccineToPetForm(AddVaccineToPetForm event, Emitter<PetsState> emit) {
    if (state is PetFormState) {
      // Simply add vaccine to form state - no Hive save needed
      final currentState = state as PetFormState;
      final updatedVaccines = List<VaccineModel>.from(currentState.vaccines)..add(event.vaccine);
      emit(currentState.copyWith(vaccines: updatedVaccines));
    }
  }

  void _onRemoveVaccineFromPetForm(RemoveVaccineFromPetForm event, Emitter<PetsState> emit) async {
    if (state is PetFormState) {
      try {
        // Remove vaccine from Hive
        await _vaccineRepository.deleteVaccine(event.vaccineId);

        // Update form state
        final currentState = state as PetFormState;
        final updatedVaccines = currentState.vaccines.where((vaccine) => vaccine.id != event.vaccineId).toList();
        emit(currentState.copyWith(vaccines: updatedVaccines));
      } catch (e) {
        emit(PetsError(message: e.toString()));
      }
    }
  }

  List<UpcomingVaccineModel> getUpcomingVaccines(List<PetModel> pets) {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    final upcomingVaccines = <UpcomingVaccineModel>[];

    for (final pet in pets) {
      for (final vaccine in pet.vaccines) {
        // Include vaccines due in the next 30 days (or overdue)
        if (vaccine.nextDueDate.isBefore(thirtyDaysFromNow) &&
            vaccine.nextDueDate.isAfter(now.subtract(const Duration(days: 1)))) {
          upcomingVaccines.add(UpcomingVaccineModel(
            vaccine: vaccine,
            petName: pet.name,
            petId: pet.id,
          ));
        }
      }
    }

    // Sort by date (soonest first)
    upcomingVaccines.sort((a, b) => a.vaccine.nextDueDate.compareTo(b.vaccine.nextDueDate));

    return upcomingVaccines;
  }
}
