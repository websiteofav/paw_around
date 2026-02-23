import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/api_constants.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/services/auth_error_interceptor.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;
  final AuthErrorInterceptor _authInterceptor = AuthErrorInterceptor();

  CommunityBloc({required CommunityRepository repository})
      : _repository = repository,
        super(CommunityInitial()) {
    on<LoadPosts>(_onLoadPosts);
    on<LoadMyPosts>(_onLoadMyPosts);
    on<CreatePost>(_onCreatePost);
    on<SelectPost>(_onSelectPost);
    on<ClearSelectedPost>(_onClearSelectedPost);
    on<MarkPostResolved>(_onMarkPostResolved);
    on<UnresolvePost>(_onUnresolvePost);
    on<DeletePost>(_onDeletePost);
  }

  Future<void> _onLoadPosts(
      LoadPosts event, Emitter<CommunityState> emit) async {
    emit(CommunityLoading());
    try {
      List<LostFoundPost> posts;
      if (event.userLocation != null) {
        // Use radius filtering if location is provided
        final radius =
            event.radiusMeters ?? ApiConstants.defaultCommunityRadius;
        posts = await _repository.getPostsWithinRadius(
          latitude: event.userLocation!.latitude,
          longitude: event.userLocation!.longitude,
          radiusMeters: radius,
        );
      } else {
        // Fallback to all posts if no location
        posts = await _repository.getPosts();
      }
      emit(CommunityLoaded(posts: posts));
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onLoadMyPosts(
      LoadMyPosts event, Emitter<CommunityState> emit) async {
    emit(MyPostsLoading());
    try {
      final posts = await _repository.getPostsByUser(event.userId);
      emit(MyPostsLoaded(posts: posts));
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onCreatePost(
      CreatePost event, Emitter<CommunityState> emit) async {
    emit(PostCreating());
    try {
      final createdPost = await _repository.createPost(event.post);
      emit(PostCreated(createdPost));
      // Reload posts after creation (without location to show all posts)
      add(const LoadPosts());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  void _onSelectPost(SelectPost event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      emit(currentState.copyWith(selectedPost: event.post));
    }
  }

  void _onClearSelectedPost(
      ClearSelectedPost event, Emitter<CommunityState> emit) {
    if (state is CommunityLoaded) {
      final currentState = state as CommunityLoaded;
      emit(currentState.copyWith(clearSelectedPost: true));
    }
  }

  Future<void> _onMarkPostResolved(
      MarkPostResolved event, Emitter<CommunityState> emit) async {
    try {
      await _repository.markAsResolved(event.postId);
      emit(PostResolved());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onUnresolvePost(
      UnresolvePost event, Emitter<CommunityState> emit) async {
    try {
      await _repository.unresolvePost(event.postId);
      emit(PostUnresolved());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _onDeletePost(
      DeletePost event, Emitter<CommunityState> emit) async {
    try {
      await _repository.deletePost(event.postId);
      emit(PostDeleted());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  Future<void> _handleUnauthorizedError(Object error) async {
    if (_authInterceptor.isUnauthorizedError(error)) {
      await _authInterceptor.handleUnauthorizedError();
    }
  }
}
