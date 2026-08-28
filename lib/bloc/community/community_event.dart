import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

abstract class CommunityEvent extends Equatable {
  const CommunityEvent();

  @override
  List<Object?> get props => [];
}

class LoadPosts extends CommunityEvent {
  final Position? userLocation;
  final int? radiusMeters;
  const LoadPosts({this.userLocation, this.radiusMeters});

  @override
  List<Object?> get props => [userLocation, radiusMeters];
}

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
  final String? petId;
  const MarkPostResolved(this.postId, {this.petId});

  @override
  List<Object?> get props => [postId, petId];
}

class UnresolvePost extends CommunityEvent {
  final String postId;
  final String? petId;
  final DateTime? lastSeenAt;
  final String? lastSeenLocation;
  const UnresolvePost(
    this.postId, {
    this.petId,
    this.lastSeenAt,
    this.lastSeenLocation,
  });

  @override
  List<Object?> get props => [postId, petId, lastSeenAt, lastSeenLocation];
}

class DeletePost extends CommunityEvent {
  final String postId;
  const DeletePost(this.postId);

  @override
  List<Object?> get props => [postId];
}

class LoadMyPosts extends CommunityEvent {
  final String userId;
  const LoadMyPosts(this.userId);

  @override
  List<Object?> get props => [userId];
}
