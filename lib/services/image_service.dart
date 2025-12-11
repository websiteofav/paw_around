// lib/services/image_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Return XFile for immediate display
  static Future<XFile?> pickPetImage() async {
    // Request permission
    if (!await _requestPermission()) return null;

    // Pick image
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    return image; // Return XFile directly
  }

  // Save image when pet is added
  static Future<String?> savePetImage(String petId, XFile image) async {
    return await _saveImageToAppDirectory(image, petId);
  }

  static Future<String?> _saveImageToAppDirectory(XFile image, String petId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory petDir = Directory('${appDir.path}/pet_photos/pet_$petId');

      if (!await petDir.exists()) {
        await petDir.create(recursive: true);
      }

      String fileName = 'profile.jpg';
      final String filePath = '${petDir.path}/$fileName';

      await File(image.path).copy(filePath);
      return filePath;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
    }
  }

  static Future<bool> _requestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true; // iOS handles permissions automatically
  }

  static Future<void> deletePetImage(String? imagePath) async {
    if (imagePath != null) {
      try {
        await File(imagePath).delete();
      } catch (e) {
        debugPrint('Error deleting image: $e');
      }
    }
  }
}
