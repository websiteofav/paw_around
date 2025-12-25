import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

/// Service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  /// Upload an image file and return the download URL
  /// Returns null if upload fails
  Future<String?> uploadPostImage({
    required String localPath,
    required String userId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return null;
      }

      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('post_images').child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Delete an image from Firebase Storage by URL
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Upload a pet profile image
  Future<String?> uploadPetImage({
    required String localPath,
    required String petId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return null;
      }

      final fileName = '${petId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('pet_images').child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  /// Upload a user profile image
  Future<String?> uploadProfileImage({
    required String localPath,
    required String userId,
  }) async {
    try {
      final file = File(localPath);
      if (!await file.exists()) {
        return null;
      }

      final fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('profile_images').child(fileName);

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }
}
