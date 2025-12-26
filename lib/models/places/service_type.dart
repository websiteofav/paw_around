import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

/// Represents the type of pet service for filtering
enum ServiceType {
  all,
  vet,
  groomer,
  petStore,
}

extension ServiceTypeExtension on ServiceType {
  /// Get the display label for the service type
  String get label {
    switch (this) {
      case ServiceType.all:
        return 'All';
      case ServiceType.vet:
        return 'Vets';
      case ServiceType.groomer:
        return 'Groomers';
      case ServiceType.petStore:
        return 'Pet Stores';
    }
  }

  /// Get the icon for the service type
  IconData get icon {
    switch (this) {
      case ServiceType.all:
        return Icons.pets;
      case ServiceType.vet:
        return Icons.local_hospital_rounded;
      case ServiceType.groomer:
        return Icons.content_cut_rounded;
      case ServiceType.petStore:
        return Icons.storefront_rounded;
    }
  }

  /// Get the background color for the service type
  Color get color {
    switch (this) {
      case ServiceType.all:
        return AppColors.primary;
      case ServiceType.vet:
        return AppColors.vetServiceBg;
      case ServiceType.groomer:
        return AppColors.groomingServiceBg;
      case ServiceType.petStore:
        return AppColors.petStoreBg;
    }
  }

  /// Get the Google Places types to filter by
  List<String> get placeTypes {
    switch (this) {
      case ServiceType.all:
        return [];
      case ServiceType.vet:
        return ['veterinary_care'];
      case ServiceType.groomer:
        return ['pet_groomer', 'groomer'];
      case ServiceType.petStore:
        return ['pet_store'];
    }
  }

  /// Check if a list of types matches this service type
  /// Also checks placeName for better categorization
  bool matchesTypes(List<String> types, {String? placeName}) {
    if (this == ServiceType.all) return true;

    final lowerTypes = types.map((t) => t.toLowerCase()).toList();
    final lowerName = placeName?.toLowerCase() ?? '';

    switch (this) {
      case ServiceType.vet:
        return lowerTypes.contains('veterinary_care') ||
            lowerName.contains('vet') ||
            lowerName.contains('veterinary') ||
            lowerName.contains('animal hospital') ||
            lowerName.contains('animal clinic');
      case ServiceType.groomer:
        return lowerTypes.any((t) => t.contains('groom') || t.contains('pet_groomer') || t == 'beauty_salon') ||
            lowerName.contains('groom');
      case ServiceType.petStore:
        return lowerTypes.contains('pet_store') || lowerName.contains('pet store') || lowerName.contains('pet shop');
      case ServiceType.all:
        return true;
    }
  }

  /// Create from a route parameter string
  static ServiceType fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'vet':
      case 'veterinary_care':
        return ServiceType.vet;
      case 'groomer':
      case 'pet_groomer':
        return ServiceType.groomer;
      case 'pet_store':
      case 'petstore':
        return ServiceType.petStore;
      default:
        return ServiceType.all;
    }
  }
}
