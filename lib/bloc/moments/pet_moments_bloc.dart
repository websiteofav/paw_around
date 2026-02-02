import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/repositories/pet_moments_repository.dart';

class PetMomentsBloc extends Bloc<PetMomentsEvent, PetMomentsState> {
  final PetMomentsRepository _repository;

  PetMomentsBloc({required PetMomentsRepository repository})
      : _repository = repository,
        super(PetMomentsInitial()) {
    on<LoadMoments>(_onLoadMoments);
    on<CreateMoment>(_onCreateMoment);
    on<LikeMoment>(_onLikeMoment);
    on<AddComment>(_onAddComment);
    on<DeleteMoment>(_onDeleteMoment);
  }

  Future<void> _onLoadMoments(
      LoadMoments event, Emitter<PetMomentsState> emit) async {
    emit(PetMomentsLoading());
    try {
      final moments = await _repository.getMoments();
      emit(PetMomentsLoaded(moments: moments));
    } catch (e) {
      emit(PetMomentsError(e.toString()));
      rethrow;
    }
  }

  Future<void> _onCreateMoment(
      CreateMoment event, Emitter<PetMomentsState> emit) async {
    emit(MomentCreating());
    try {
      final createdMoment = await _repository.createMoment(event.moment);
      emit(MomentCreated(createdMoment));
      // Reload moments after creation
      add(const LoadMoments());
    } catch (e) {
      emit(PetMomentsError(e.toString()));
      rethrow;
    }
  }

  Future<void> _onLikeMoment(
      LikeMoment event, Emitter<PetMomentsState> emit) async {
    try {
      await _repository.likeMoment(event.momentId, event.userId);
      // Reload moments to get updated like count
      add(const LoadMoments());
    } catch (e) {
      emit(PetMomentsError(e.toString()));
      rethrow;
    }
  }

  Future<void> _onAddComment(
      AddComment event, Emitter<PetMomentsState> emit) async {
    try {
      await _repository.addComment(
        event.momentId,
        event.userId,
        event.userName,
        event.text,
      );
      // Reload moments to get updated comment count
      add(const LoadMoments());
    } catch (e) {
      emit(PetMomentsError(e.toString()));
      rethrow;
    }
  }

  Future<void> _onDeleteMoment(
      DeleteMoment event, Emitter<PetMomentsState> emit) async {
    try {
      await _repository.deleteMoment(event.momentId);
      emit(MomentDeleted());
      // Reload moments after deletion
      add(const LoadMoments());
    } catch (e) {
      emit(PetMomentsError(e.toString()));
      rethrow;
    }
  }
}
