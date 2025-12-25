import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_event.dart';
import 'package:paw_around/bloc/pets/pet_list/pet_list_state.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/vaccines/upcoming_vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';

class PetListBloc extends Bloc<PetListEvent, PetListState> {
  final PetRepository _petRepository;

  PetListBloc({
    required PetRepository petRepository,
  })  : _petRepository = petRepository,
        super(const PetListInitial()) {
    on<LoadPetList>(_onLoadPetList);
    on<DeletePet>(_onDeletePet);
  }

  Future<void> _onLoadPetList(LoadPetList event, Emitter<PetListState> emit) async {
    emit(const PetListLoading());

    try {
      final pets = await _petRepository.getAllPets();
      emit(PetListLoaded(pets: pets));
    } catch (e) {
      emit(PetListError(message: e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  Future<void> _onDeletePet(DeletePet event, Emitter<PetListState> emit) async {
    try {
      await _petRepository.deletePet(event.petId);
      emit(PetDeleted(petId: event.petId));

      // Reload the list after deletion
      add(const LoadPetList());
    } catch (e) {
      emit(PetListError(message: e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  /// Helper method to get upcoming vaccines from loaded pets
  List<UpcomingVaccineModel> getUpcomingVaccines(List<PetModel> pets) {
    final now = DateTime.now();
    final thirtyDaysFromNow = now.add(const Duration(days: 30));

    final upcomingVaccineList = <UpcomingVaccineModel>[];

    for (final pet in pets) {
      for (final vaccine in pet.vaccines) {
        if (vaccine.nextDueDate.isBefore(thirtyDaysFromNow) &&
            vaccine.nextDueDate.isAfter(now.subtract(const Duration(days: 1)))) {
          upcomingVaccineList.add(UpcomingVaccineModel(
            vaccine: vaccine,
            petName: pet.name,
            petId: pet.id,
          ));
        }
      }
    }

    upcomingVaccineList.sort((a, b) => a.vaccine.nextDueDate.compareTo(b.vaccine.nextDueDate));

    return upcomingVaccineList;
  }
}
