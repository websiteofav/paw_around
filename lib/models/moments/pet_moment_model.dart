import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PetMomentComment extends Equatable {
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  const PetMomentComment({
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory PetMomentComment.fromMap(Map<String, dynamic> map) {
    return PetMomentComment(
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      text: map['text'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  @override
  List<Object?> get props => [userId, userName, text, createdAt];
}

class PetMoment extends Equatable {
  final String id;
  final String petId;
  final String petName;
  final String imageUrl;
  final String caption;
  final String userId;
  final String userName;
  final DateTime createdAt;
  final List<String> likes;
  final List<PetMomentComment> comments;

  const PetMoment({
    required this.id,
    required this.petId,
    required this.petName,
    required this.imageUrl,
    required this.caption,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.likes = const [],
    this.comments = const [],
  });

  /// Create from Firestore document
  factory PetMoment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse likes array
    final likesList = data['likes'] as List<dynamic>? ?? [];
    final likes = likesList.map((e) => e.toString()).toList();

    // Parse comments array
    final commentsList = data['comments'] as List<dynamic>? ?? [];
    final comments = commentsList
        .map((e) => PetMomentComment.fromMap(e as Map<String, dynamic>))
        .toList();

    return PetMoment(
      id: doc.id,
      petId: data['petId'] ?? '',
      petName: data['petName'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      likes: likes,
      comments: comments,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'petId': petId,
      'petName': petName,
      'imageUrl': imageUrl,
      'caption': caption,
      'userId': userId,
      'userName': userName,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
      'comments': comments.map((c) => c.toMap()).toList(),
    };
  }

  /// Copy with modifications
  PetMoment copyWith({
    String? id,
    String? petId,
    String? petName,
    String? imageUrl,
    String? caption,
    String? userId,
    String? userName,
    DateTime? createdAt,
    List<String>? likes,
    List<PetMomentComment>? comments,
  }) {
    return PetMoment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      imageUrl: imageUrl ?? this.imageUrl,
      caption: caption ?? this.caption,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
    );
  }

  /// Check if moment is liked by a specific user
  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  /// Get like count
  int get likeCount => likes.length;

  /// Get comment count
  int get commentCount => comments.length;

  /// Check if moment is owned by a specific user
  bool isOwnedBy(String userId) {
    return this.userId == userId;
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        petName,
        imageUrl,
        caption,
        userId,
        userName,
        createdAt,
        likes,
        comments,
      ];
}
