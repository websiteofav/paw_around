import 'package:flutter/material.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/community/lost_found_post.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/repositories/auth_repository.dart';
import 'package:paw_around/services/storage_service.dart';

/// Builds the [LostFoundPost] to submit, uploading a newly picked photo
/// first if one was selected. Returns null if the upload fails.
class CreatePostSubmitService {
  CreatePostSubmitService._();

  static Future<LostFoundPost?> buildPost({
    required PostType postType,
    required PetModel? selectedPet,
    required String? localImagePath,
    required TextEditingController breedController,
    required TextEditingController colorController,
    required TextEditingController descriptionController,
    required TextEditingController locationController,
    required TextEditingController phoneController,
    required double latitude,
    required double longitude,
    required DateTime lastSeenAt,
  }) async {
    final currentUser = sl<AuthRepository>().currentUser;
    String? imageUrl = selectedPet?.imagePath;

    if (localImagePath != null) {
      imageUrl = await sl<StorageService>().uploadPostImage(
        localPath: localImagePath,
        userId: currentUser?.uid ?? 'anonymous',
      );
      if (imageUrl == null) return null;
    }

    return LostFoundPost(
      id: '',
      type: postType,
      petId: selectedPet?.id,
      petName: selectedPet?.name ?? '',
      breed: breedController.text.trim(),
      color: colorController.text.trim(),
      petDescription: descriptionController.text.trim(),
      imagePath: imageUrl,
      latitude: latitude,
      longitude: longitude,
      locationName: locationController.text.trim(),
      lastSeenAt: lastSeenAt,
      contactPhone: phoneController.text.trim(),
      userId: currentUser?.uid ?? '',
      userName: currentUser?.displayName ?? 'Anonymous',
      createdAt: DateTime.now(),
    );
  }
}
