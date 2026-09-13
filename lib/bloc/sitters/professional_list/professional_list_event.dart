import 'package:equatable/equatable.dart';

abstract class ProfessionalListEvent extends Equatable {
  const ProfessionalListEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfessionals extends ProfessionalListEvent {
  const LoadProfessionals();
}
