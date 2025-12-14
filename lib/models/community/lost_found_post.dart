import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PostType { lost, found }

class LostFoundPost extends Equatable {
  final String id;
  final PostType type;
  final String petName;
  final String petDescription;
  final String breed;
  final String color;
  final String? imagePath;
  final double latitude;
  final double longitude;
  final String locationName;
  final String contactPhone;
  final String userId;
  final DateTime createdAt;
  final bool isResolved;

  const LostFoundPost({
    required this.id,
    required this.type,
    required this.petName,
    required this.petDescription,
    required this.breed,
    required this.color,
    this.imagePath,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.contactPhone,
    required this.userId,
    required this.createdAt,
    this.isResolved = false,
  });

  /// Create from Firestore document
  factory LostFoundPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LostFoundPost(
      id: doc.id,
      type: data['type'] == 'lost' ? PostType.lost : PostType.found,
      petName: data['petName'] ?? '',
      petDescription: data['petDescription'] ?? '',
      breed: data['breed'] ?? '',
      color: data['color'] ?? '',
      imagePath: data['imagePath'],
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      locationName: data['locationName'] ?? '',
      contactPhone: data['contactPhone'] ?? '',
      userId: data['userId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isResolved: data['isResolved'] ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'type': type == PostType.lost ? 'lost' : 'found',
      'petName': petName,
      'petDescription': petDescription,
      'breed': breed,
      'color': color,
      'imagePath': imagePath,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'contactPhone': contactPhone,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isResolved': isResolved,
    };
  }

  /// Copy with modifications
  LostFoundPost copyWith({
    String? id,
    PostType? type,
    String? petName,
    String? petDescription,
    String? breed,
    String? color,
    String? imagePath,
    double? latitude,
    double? longitude,
    String? locationName,
    String? contactPhone,
    String? userId,
    DateTime? createdAt,
    bool? isResolved,
  }) {
    return LostFoundPost(
      id: id ?? this.id,
      type: type ?? this.type,
      petName: petName ?? this.petName,
      petDescription: petDescription ?? this.petDescription,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      imagePath: imagePath ?? this.imagePath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      contactPhone: contactPhone ?? this.contactPhone,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  /// Check if post is for a lost pet
  bool get isLost => type == PostType.lost;

  /// Check if post is for a found pet
  bool get isFound => type == PostType.found;

  /// Get directions URL
  String get directionsUrl {
    return 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
  }

  @override
  List<Object?> get props => [id, type, petName, latitude, longitude, createdAt];
}
