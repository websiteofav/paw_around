import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/repositories/community_repository.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;

  CommunityBloc({required CommunityRepository repository})
      : _repository = repository,
        super(CommunityInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<CreatePost>(_onCreatePost);
    on<SelectPost>(_onSelectPost);
    on<ClearSelectedPost>(_onClearSelectedPost);
    on<MarkPostResolved>(_onMarkPostResolved);
    on<DeletePost>(_onDeletePost);
  }

  Future<void> _onLoadPosts(LoadPosts event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      final posts = await _repository.getPosts();
      emit(CommunityLoaded(posts: posts));
    } catch (e) {
      emit(CommunityError(e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  Future<void> _onCreatePost(CreatePost event, Emitter<CommunityState> emit) async {
    emit(PostCreating());
    try {
      final createdPost = await _repository.createPost(event.post);
      emit(PostCreated(createdPost));
      // Reload posts after creation
      add(LoadPosts());
    } catch (e) {
      emit(CommunityError(e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  void _onSelectPost(SelectPost event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      emit(currentState.copyWith(selectedPost: event.post));
    }
  }

  void _onClearSelectedPost(ClearSelectedPost event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      emit(currentState.copyWith(clearSelectedPost: true));
    }
  }

  Future<void> _onMarkPostResolved(MarkPostResolved event, Emitter<CommunityState> emit) async {
    try {
      await _repository.markAsResolved(event.postId);
      add(LoadPosts());
    } catch (e) {
      emit(CommunityError(e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }

  Future<void> _onDeletePost(DeletePost event, Emitter<CommunityState> emit) async {
    try {
      await _repository.deletePost(event.postId);
      emit(PostDeleted());
      add(LoadPosts());
    } catch (e) {
      emit(CommunityError(e.toString()));
      rethrow; // Let AuthBlocObserver handle auth errors
    }
  }
}
