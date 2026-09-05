import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/location_autocomplete_field.dart';

/// Floating-pill chrome around the shared [LocationAutocompleteField] for
/// the Pick Location screen's search bar.
class PickLocationSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final OnPlaceSelected onPlaceSelected;

  const PickLocationSearchBar({
    super.key,
    required this.controller,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: smoothDecoration(
        cornerRadius: 12,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.neutral300),
      ),
      child: LocationAutocompleteField(
        controller: controller,
        hintText: AppStrings.sitterSearchLocationHint,
        showCurrentLocationButton: false,
        fillColor: AppColors.white,
        onPlaceSelected: onPlaceSelected,
      ),
    );
  }
}
