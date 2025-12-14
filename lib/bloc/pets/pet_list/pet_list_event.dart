import 'package:equatable/equatable.dart';

abstract class PetListEvent extends Equatable {
  const PetListEvent();

  @override
  List<Object?> get props => [];
}

class LoadPetList extends PetListEvent {
  const LoadPetList();
}

class DeletePet extends PetListEvent {
  final String petId;

  const DeletePet({required this.petId});

  @override
  List<Object?> get props => [petId];
}
