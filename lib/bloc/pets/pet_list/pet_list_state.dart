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

  const PetListLoaded({required this.pets});

  @override
  List<Object?> get props => [pets];
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
