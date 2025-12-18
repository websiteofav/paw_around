import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_strings.dart';

/// Represents the type of action card (vaccine, grooming, tick & flea)
enum ActionType {
  vaccine,
  grooming,
  tickFlea,
}

extension ActionTypeExtension on ActionType {
  /// Get the display title for the action type
  String get title {
    switch (this) {
      case ActionType.vaccine:
        return AppStrings.vaccine;
      case ActionType.grooming:
        return AppStrings.grooming;
      case ActionType.tickFlea:
        return AppStrings.tickFleaPrevention;
    }
  }

  /// Get the icon for the action type
  IconData get icon {
    switch (this) {
      case ActionType.vaccine:
        return Icons.vaccines_outlined;
      case ActionType.grooming:
        return Icons.pets;
      case ActionType.tickFlea:
        return Icons.shield_outlined;
    }
  }

  /// Get the primary CTA button text
  String get ctaText {
    switch (this) {
      case ActionType.vaccine:
        return AppStrings.findNearbyVets;
      case ActionType.grooming:
        return AppStrings.findGroomers;
      case ActionType.tickFlea:
        return AppStrings.viewTreatmentOptions;
    }
  }

  /// Get the "Why this matters" explanation text
  String get whyItMatters {
    switch (this) {
      case ActionType.vaccine:
        return AppStrings.vaccineExplanation;
      case ActionType.grooming:
        return AppStrings.groomingExplanation;
      case ActionType.tickFlea:
        return AppStrings.tickFleaExplanation;
    }
  }

  /// Get the helper text for nearby services
  String get helperText {
    switch (this) {
      case ActionType.vaccine:
        return AppStrings.vetsAvailableNearby;
      case ActionType.grooming:
        return AppStrings.groomersAvailableNearby;
      case ActionType.tickFlea:
        return AppStrings.treatmentOptionsAvailable;
    }
  }
}
