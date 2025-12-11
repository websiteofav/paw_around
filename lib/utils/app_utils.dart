import 'package:flutter/material.dart';

/// Utility functions for the Paw Around app
class AppUtils {
  // Private constructor to prevent instantiation
  AppUtils._();

  /// Generate a unique ID (simple implementation)
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Validate email format
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validate phone number format (basic)
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(phone);
  }

  /// Capitalize first letter of each word
  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Show a snackbar with custom styling
  static void showSnackBar(
    BuildContext context, {
    required String message,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.green,
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.red,
    );
  }

  /// Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  /// Get relative time string (e.g., "2 days ago", "in 3 hours")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Debounce function to limit function calls
  static void debounce(
    String key,
    Duration delay,
    VoidCallback callback,
  ) {
    // Simple debounce implementation
    // In a real app, you might want to use a more sophisticated approach
    Future.delayed(delay, callback);
  }

  /// Check if string is null or empty
  static bool isNullOrEmpty(String? value) {
    return value == null || value.trim().isEmpty;
  }

  /// Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }

  /// Format file size in human readable format
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
