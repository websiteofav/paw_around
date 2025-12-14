import 'package:equatable/equatable.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosts extends CommunityEvent {}

class CreatePost extends CommunityEvent {
  final LostFoundPost post;
  const CreatePost(this.post);

  @override
  List<Object?> get props => [post];
}

class SelectPost extends CommunityEvent {
  final LostFoundPost post;
  const SelectPost(this.post);

  @override
  List<Object?> get props => [post];
}

class ClearSelectedPost extends CommunityEvent {}

class MarkPostResolved extends CommunityEvent {
  final String postId;
  const MarkPostResolved(this.postId);

  @override
  List<Object?> get props => [postId];
}

class DeletePost extends CommunityEvent {
  final String postId;
  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}
