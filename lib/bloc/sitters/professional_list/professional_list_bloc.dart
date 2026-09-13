import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/sitters/professional_list/professional_list_event.dart';
import 'package:paw_around/bloc/sitters/professional_list/professional_list_state.dart';
import 'package:paw_around/repositories/professional_repository.dart';

class ProfessionalListBloc extends Bloc<ProfessionalListEvent, ProfessionalListState> {
  final ProfessionalRepository _professionalRepository;

  ProfessionalListBloc({required ProfessionalRepository professionalRepository})
      : _professionalRepository = professionalRepository,
        super(const ProfessionalListInitial()) {
    on<LoadProfessionals>(_onLoadProfessionals);
  }

  Future<void> _onLoadProfessionals(
      LoadProfessionals event, Emitter<ProfessionalListState> emit) async {
    emit(const ProfessionalListLoading());
    try {
      final professionals = await _professionalRepository.getAllProfessionals();
      emit(ProfessionalListLoaded(professionals: professionals));
    } catch (e) {
      emit(ProfessionalListError(message: e.toString()));
    }
  }
}
