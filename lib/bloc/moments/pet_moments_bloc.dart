import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/moments/pet_moments_event.dart';
import 'package:paw_around/bloc/moments/pet_moments_state.dart';
import 'package:paw_around/models/moments/pet_moment_model.dart';
import 'package:paw_around/repositories/pet_moments_repository.dart';
import 'package:paw_around/services/auth_error_interceptor.dart';

class PetMomentsBloc extends Bloc<PetMomentsEvent, PetMomentsState> {
  final PetMomentsRepository _repository;
  final AuthErrorInterceptor _authInterceptor = AuthErrorInterceptor();

  PetMomentsBloc({required PetMomentsRepository repository})
      : _repository = repository,
        super(PetMomentsInitial()) {
    on<LoadMoments>(_onLoadMoments);
    on<LoadMyMoments>(_onLoadMyMoments);
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
      await _handleUnauthorizedError(e);
      emit(PetMomentsError(e.toString()));
    }
  }

  Future<void> _onLoadMyMoments(
      LoadMyMoments event, Emitter<PetMomentsState> emit) async {
    emit(PetMomentsLoading());
    try {
      final moments = await _repository.getMomentsByUserId(event.userId);
      emit(PetMomentsLoaded(moments: moments));
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(PetMomentsError(e.toString()));
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
      await _handleUnauthorizedError(e);
      emit(PetMomentsError(e.toString()));
    }
  }

  Future<void> _onLikeMoment(
      LikeMoment event, Emitter<PetMomentsState> emit) async {
    final currentState = state;
    List<PetMoment>? previousMoments;
    if (currentState is PetMomentsLoaded) {
      previousMoments = currentState.moments;
      final updatedMoments = previousMoments.map((moment) {
        if (moment.id != event.momentId) return moment;
        final likes = List<String>.from(moment.likes);
        if (likes.contains(event.userId)) {
          likes.remove(event.userId);
        } else {
          likes.add(event.userId);
        }
        return moment.copyWith(likes: likes);
      }).toList();
      emit(PetMomentsLoaded(moments: updatedMoments));
    }
    try {
      await _repository.likeMoment(event.momentId, event.userId);
    } catch (e) {
      await _handleUnauthorizedError(e);
      if (previousMoments != null) {
        emit(PetMomentsLoaded(moments: previousMoments));
      }
      emit(PetMomentsError(e.toString()));
    }
  }

  Future<void> _onAddComment(
      AddComment event, Emitter<PetMomentsState> emit) async {
    final currentState = state;
    List<PetMoment>? previousMoments;
    if (currentState is PetMomentsLoaded) {
      previousMoments = currentState.moments;
      final newComment = PetMomentComment(
        userId: event.userId,
        userName: event.userName,
        text: event.text,
        createdAt: DateTime.now(),
      );
      final updatedMoments = previousMoments.map((moment) {
        if (moment.id != event.momentId) return moment;
        final comments = List<PetMomentComment>.from(moment.comments)
          ..add(newComment);
        return moment.copyWith(comments: comments);
      }).toList();
      emit(PetMomentsLoaded(moments: updatedMoments));
    }
    try {
      await _repository.addComment(
        event.momentId,
        event.userId,
        event.userName,
        event.text,
      );
    } catch (e) {
      await _handleUnauthorizedError(e);
      if (previousMoments != null) {
        emit(PetMomentsLoaded(moments: previousMoments));
      }
      emit(PetMomentsError(e.toString()));
    }
  }

  Future<void> _onDeleteMoment(
      DeleteMoment event, Emitter<PetMomentsState> emit) async {
    try {
      await _repository.deleteMoment(event.momentId);
      emit(MomentDeleted());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(PetMomentsError(e.toString()));
    }
  }

  Future<void> _handleUnauthorizedError(Object error) async {
    if (_authInterceptor.isUnauthorizedError(error)) {
      await _authInterceptor.handleUnauthorizedError();
    }
  }
}
