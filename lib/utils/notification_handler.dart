import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/core/di/service_locator.dart';
import 'package:paw_around/models/pets/action_type.dart';
import 'package:paw_around/models/vaccines/vaccine_model.dart';
import 'package:paw_around/repositories/pet_repository.dart';
import 'package:paw_around/router/app_router.dart';
import 'package:paw_around/ui/home/action_card_detail_screen.dart';

/// Handles navigation when notifications are tapped
class NotificationHandler {
  /// Handle notification tap and navigate to relevant screen
  static Future<void> handleNotificationTap(
      NotificationResponse response) async {
    if (response.payload == null || response.payload!.isEmpty) {
      debugPrint('Notification tapped but no payload');
      return;
    }

    try {
      final payload = jsonDecode(response.payload!) as Map<String, dynamic>;
      await _navigateFromNotification(payload);
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
      // On error, navigate to home
      _navigateToHome();
    }
  }

  /// Navigate to the appropriate screen based on notification payload
  static Future<void> _navigateFromNotification(
      Map<String, dynamic> payload) async {
    final petId = payload['petId'] as String?;
    final reminderType = payload['reminderType'] as String?;
    final vaccineId = payload['vaccineId'] as String?;

    if (petId == null) {
      debugPrint('Notification payload missing petId');
      return;
    }

    // Get the router
    final router = AppRouter.router;

    // Fetch pet from repository
    final petRepository = sl<PetRepository>();
    final pet = await petRepository.getPetById(petId);

    if (pet == null) {
      debugPrint('Pet not found: $petId');
      // Navigate to home if pet not found
      router.go(AppRoutes.home);
      return;
    }

    // Navigate based on reminder type - all go to actionDetail
    if (reminderType == 'vaccine' && vaccineId != null) {
      // Find the specific vaccine from pet's vaccines
      VaccineModel? vaccine;
      try {
        vaccine = pet.vaccines.firstWhere(
          (v) => v.id == vaccineId,
        );
      } catch (_) {
        // If vaccine not found, use the first vaccine or null
        vaccine = pet.vaccines.isNotEmpty ? pet.vaccines.first : null;
      }

      if (vaccine != null) {
        router.pushNamed(
          AppRoutes.actionDetail,
          extra: ActionCardData(
            actionType: ActionType.vaccine,
            pet: pet,
            vaccine: vaccine,
            customTitle: vaccine.vaccineName,
          ),
        );
      } else {
        // No vaccines found, navigate to home
        router.go(AppRoutes.home);
      }
    } else if (reminderType == 'grooming') {
      // Navigate to action detail for grooming
      router.pushNamed(
        AppRoutes.actionDetail,
        extra: ActionCardData(
          actionType: ActionType.grooming,
          pet: pet,
        ),
      );
    } else if (reminderType == 'tickFlea') {
      // Navigate to action detail for tick/flea
      router.pushNamed(
        AppRoutes.actionDetail,
        extra: ActionCardData(
          actionType: ActionType.tickFlea,
          pet: pet,
        ),
      );
    } else {
      // Default: navigate to home
      router.go(AppRoutes.home);
    }
  }

  /// Navigate to home screen (fallback)
  static void _navigateToHome() {
    try {
      AppRouter.router.go(AppRoutes.home);
    } catch (_) {
      // Router not available
      debugPrint('Router not available for navigation');
    }
  }
}
