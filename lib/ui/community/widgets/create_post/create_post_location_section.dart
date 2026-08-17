import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';
import 'package:paw_around/ui/widgets/location_autocomplete_field.dart';
import 'package:paw_around/utils/validators.dart';

/// "Where did you see {pet}?" location field + info banner.
class CreatePostLocationSection extends StatelessWidget {
  final String? petName;
  final TextEditingController controller;
  final OnPlaceSelected onPlaceSelected;

  const CreatePostLocationSection({
    super.key,
    required this.petName,
    required this.controller,
    required this.onPlaceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final hasPetName = petName != null && petName!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          hasPetName
              ? '${AppStrings.whereDidYouSee} $petName?'
              : AppStrings.whereDidYouSeeThisPet,
          style: AppTextStyles.semiBoldStyle600(
              fontSize: 13, fontColor: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        LocationAutocompleteField(
          controller: controller,
          hintText: AppStrings.searchForLocation,
          validator: (value) =>
              Validators.required(value, AppStrings.location),
          showCurrentLocationButton: true,
          onPlaceSelected: onPlaceSelected,
        ),
        const SizedBox(height: 12),
        const InfoBanner(
            text: AppStrings.accurateLocationHelpsPeopleRespondFaster),
      ],
    );
  }
}
