import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for handling Lottie animations from Firebase Storage with local caching
class AnimationService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _cachePrefix = 'lottie_cache_';
  static const String _lottieFolder = 'app_lotties';

  /// Get Lottie file (from cache or download from Firebase Storage)
  /// Returns local file path if cached, network URL if not cached, or null if failed
  /// The returned path can be used with Lottie.asset() (if local) or Lottie.network() (if URL)
  static Future<String?> getLottieFile(String fileName) async {
    try {
      // Check cache first
      final cachedPath = await _getCachedPath(fileName);
      if (cachedPath != null && await File(cachedPath).exists()) {
        return cachedPath;
      }

      // Download from Firebase Storage
      final ref = _storage.ref().child(_lottieFolder).child(fileName);
      final downloadUrl = await ref.getDownloadURL();

      // Try to download and cache the file
      try {
        final response = await http.get(Uri.parse(downloadUrl));
        if (response.statusCode == 200) {
          final cachePath = await _saveToCache(fileName, response.bodyBytes);
          if (cachePath != null) {
            return cachePath;
          }
        }
      } catch (e) {
        debugPrint('Error caching Lottie file: $e');
        // Fall through to return network URL
      }

      // Fallback to network URL if caching fails
      return downloadUrl;
    } catch (e) {
      debugPrint('Error loading Lottie animation: $e');
      return null;
    }
  }

  /// Get download URL directly from Firebase Storage (without caching)
  /// Useful for direct network loading
  static Future<String?> getLottieUrl(String fileName) async {
    try {
      final ref = _storage.ref().child(_lottieFolder).child(fileName);
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error getting Lottie URL: $e');
      return null;
    }
  }

  /// Get cached file path
  static Future<String?> _getCachedPath(String fileName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('$_cachePrefix$fileName');
    } catch (e) {
      debugPrint('Error getting cached path: $e');
      return null;
    }
  }

  /// Save file to cache
  static Future<String?> _saveToCache(String fileName, List<int> data) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/lottie_cache');
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      final file = File('${cacheDir.path}/$fileName');
      await file.writeAsBytes(data);

      // Save path to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_cachePrefix$fileName', file.path);

      return file.path;
    } catch (e) {
      debugPrint('Error saving to cache: $e');
      return null;
    }
  }

  /// Clear cache (useful when updating animations)
  static Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${dir.path}/lottie_cache');
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith(_cachePrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Clear cache for a specific file
  static Future<void> clearCacheForFile(String fileName) async {
    try {
      final cachedPath = await _getCachedPath(fileName);
      if (cachedPath != null) {
        final file = File(cachedPath);
        if (await file.exists()) {
          await file.delete();
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$fileName');
    } catch (e) {
      debugPrint('Error clearing cache for file: $e');
    }
  }
}
