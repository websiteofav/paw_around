import 'package:equatable/equatable.dart';
import 'package:paw_around/models/sitters/professional_model.dart';

abstract class ProfessionalListState extends Equatable {
  const ProfessionalListState();

  @override
  List<Object?> get props => [];
}

class ProfessionalListInitial extends ProfessionalListState {
  const ProfessionalListInitial();
}

class ProfessionalListLoading extends ProfessionalListState {
  const ProfessionalListLoading();
}

class ProfessionalListLoaded extends ProfessionalListState {
  final List<ProfessionalModel> professionals;

  const ProfessionalListLoaded({required this.professionals});

  @override
  List<Object?> get props => [professionals];
}

class ProfessionalListError extends ProfessionalListState {
  final String message;

  const ProfessionalListError({required this.message});

  @override
  List<Object?> get props => [message];
}
