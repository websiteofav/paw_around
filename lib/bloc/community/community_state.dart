import 'package:equatable/equatable.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();

  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<LostFoundPost> posts;
  final LostFoundPost? selectedPost;

  const CommunityLoaded({
    required this.posts,
    this.selectedPost,
  });

  @override
  List<Object?> get props => [posts, selectedPost];

  CommunityLoaded copyWith({
    List<LostFoundPost>? posts,
    LostFoundPost? selectedPost,
    bool clearSelectedPost = false,
  }) {
    return CommunityLoaded(
      posts: posts ?? this.posts,
      selectedPost: clearSelectedPost ? null : selectedPost ?? this.selectedPost,
    );
  }
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostCreating extends CommunityState {}

class PostCreated extends CommunityState {
  final LostFoundPost post;
  const PostCreated(this.post);

  @override
  List<Object?> get props => [post];
}

class PostDeleted extends CommunityState {}
