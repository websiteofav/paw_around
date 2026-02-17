import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/models/public_pet/public_pet_last_seen.dart';
import 'package:paw_around/models/public_pet/public_pet_owner.dart';

/// Public profile for the unauthenticated public pet page (pet + owner + last-seen).
class PublicPetProfile extends Equatable {
  final PetModel pet;
  final PublicPetOwner? owner;
  final PublicPetLastSeen? lastSeen;

  const PublicPetProfile({
    required this.pet,
    this.owner,
    this.lastSeen,
  });

  /// Builds from Firestore document data (e.g. snapshot.data()).
  /// Handles nested [pet] map with Timestamp or ISO date strings.
  static PublicPetProfile? fromMap(Map<String, dynamic>? map) {
    if (map == null) return null;
    final petMap = map['pet'] as Map<String, dynamic>?;
    if (petMap == null) return null;
    final pet = _petFromMap(petMap);
    if (pet == null) return null;
    return PublicPetProfile(
      pet: pet,
      owner: PublicPetOwner.fromMap(map['owner'] as Map<String, dynamic>?),
      lastSeen:
          PublicPetLastSeen.fromMap(map['lastSeen'] as Map<String, dynamic>?),
    );
  }

  /// Converts Firestore-style pet map (Timestamps) to PetModel.
  static PetModel? _petFromMap(Map<String, dynamic> data) {
    try {
      final json = _firestoreMapToJson(data);
      json['id'] ??= data['id'] as String? ?? '';
      json['name'] ??= data['name'] as String? ?? '';
      json['species'] ??= data['species'] as String? ?? '';
      json['breed'] ??= data['breed'] as String? ?? '';
      json['gender'] ??= data['gender'] as String? ?? '';
      json['notes'] ??= data['notes'] as String? ?? '';
      json['weight'] ??= data['weight'] as num? ?? 0;
      if (json['dateOfBirth'] == null ||
          json['createdAt'] == null ||
          json['updatedAt'] == null) {
        return null;
      }
      return PetModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _firestoreMapToJson(Map<String, dynamic> data) {
    final json = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is Timestamp) {
        json[key] = value.toDate().toIso8601String();
      } else if (value is List && key == 'vaccines') {
        json[key] = (value as List)
            .map((v) => _firestoreMapToJson(v as Map<String, dynamic>))
            .toList();
      } else if (value is Map &&
          (key == 'groomingSettings' || key == 'tickFleaSettings')) {
        json[key] = _firestoreMapToJson(value as Map<String, dynamic>);
      } else {
        json[key] = value;
      }
    }
    return json;
  }

  @override
  List<Object?> get props => [pet, owner, lastSeen];
}
