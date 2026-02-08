import 'package:equatable/equatable.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';

abstract class PetMomentsState extends Equatable {
  const PetMomentsState();

  @override
  List<Object?> get props => [];
}

class PetMomentsInitial extends PetMomentsState {}

class PetMomentsLoading extends PetMomentsState {}

class PetMomentsLoaded extends PetMomentsState {
  final List<PetMoment> moments;

  const PetMomentsLoaded({required this.moments});

  @override
  List<Object?> get props => [moments];
}

class PetMomentsError extends PetMomentsState {
  final String message;
  const PetMomentsError(this.message);

  @override
  List<Object?> get props => [message];
}

class MomentCreating extends PetMomentsState {}

class MomentCreated extends PetMomentsState {
  final PetMoment moment;
  const MomentCreated(this.moment);

  @override
  List<Object?> get props => [moment];
}

class MomentDeleted extends PetMomentsState {}
