import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';

abstract class PetListState extends Equatable {
  const PetListState();

  @override
  List<Object?> get props => [];
}

class PetListInitial extends PetListState {
  const PetListInitial();
}

class PetListLoading extends PetListState {
  const PetListLoading();
}

class PetListLoaded extends PetListState {
  final List<PetModel> pets;
  final String? selectedPetId;

  const PetListLoaded({required this.pets, this.selectedPetId});

  /// Get the currently selected pet, or the first pet if none selected
  PetModel? get selectedPet {
    if (pets.isEmpty) return null;
    if (selectedPetId == null) return pets.first;
    return pets.firstWhere(
      (p) => p.id == selectedPetId,
      orElse: () => pets.first,
    );
  }

  PetListLoaded copyWith({
    List<PetModel>? pets,
    String? selectedPetId,
  }) {
    return PetListLoaded(
      pets: pets ?? this.pets,
      selectedPetId: selectedPetId ?? this.selectedPetId,
    );
  }

  @override
  List<Object?> get props => [pets, selectedPetId];
}

class PetListError extends PetListState {
  final String message;

  const PetListError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PetDeleted extends PetListState {
  final String petId;

  const PetDeleted({required this.petId});

  @override
  List<Object?> get props => [petId];
}
