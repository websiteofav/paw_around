import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/location_autocomplete_field.dart';

/// Optional "Add location" field, reusing the same place-autocomplete +
/// current-location pattern as the Lost & Found post screen.
class CreateMomentLocationSection extends StatelessWidget {
  final TextEditingController controller;
  final OnPlaceSelected onPlaceSelected;

  const CreateMomentLocationSection({
    super.key,
    required this.controller,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.addLocationLabel,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          controller: controller,
          hintText: AppStrings.searchForLocation,
          showCurrentLocationButton: true,
          onPlaceSelected: onPlaceSelected,
        ),
      ],
    );
  }
}
