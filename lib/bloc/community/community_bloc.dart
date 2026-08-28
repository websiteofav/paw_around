import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/community/community_event.dart';
import 'package:paw_around/bloc/community/community_state.dart';
import 'package:paw_around/constants/api_constants.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/repositories/community_repository.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/services/auth_error_interceptor.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final CommunityRepository _repository;
  final PetRepository _petRepository;
  final AuthErrorInterceptor _authInterceptor = AuthErrorInterceptor();

  CommunityBloc({
    required CommunityRepository repository,
    required PetRepository petRepository,
  })  : _repository = repository,
        _petRepository = petRepository,
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
      await _syncPetLostState(createdPost);
      emit(PostCreated(createdPost));
      // Reload posts after creation (without location to show all posts)
      add(const LoadPosts());
    } catch (e) {
      await _handleUnauthorizedError(e);
      emit(CommunityError(e.toString()));
    }
  }

  /// Keeps the linked pet's own lost/found state (surfaced on its public
  /// QR page) consistent with a "lost" post created for it.
  Future<void> _syncPetLostState(LostFoundPost post) async {
    if (post.type != PostType.lost || post.petId == null) return;
    final pet = await _petRepository.getPetById(post.petId!);
    if (pet == null) return;
    await _petRepository.updatePet(
      pet.copyWith(
        isLost: true,
        lastSeenAt: post.lastSeenAt ?? post.createdAt,
        lastSeenLocation:
            post.locationName.isEmpty ? null : post.locationName,
        updatedAt: DateTime.now(),
      ),
    );
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
      if (event.petId != null) {
        final pet = await _petRepository.getPetById(event.petId!);
        if (pet != null) {
          await _petRepository.updatePet(
            pet.copyWith(
              isLost: false,
              lastSeenAt: null,
              lastSeenLocation: null,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
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
      if (event.petId != null) {
        final pet = await _petRepository.getPetById(event.petId!);
        if (pet != null) {
          await _petRepository.updatePet(
            pet.copyWith(
              isLost: true,
              lastSeenAt: event.lastSeenAt ?? DateTime.now(),
              lastSeenLocation: event.lastSeenLocation,
              updatedAt: DateTime.now(),
            ),
          );
        }
      }
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
