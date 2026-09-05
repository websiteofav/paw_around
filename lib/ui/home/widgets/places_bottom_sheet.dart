import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/home/widgets/place_card.dart';

class PlacesBottomSheet extends StatelessWidget {
  final List<PlacesModel> places;
  final String? selectedPlaceId;
  final Function(PlacesModel)? onDirectionsTap;

  const PlacesBottomSheet({
    super.key,
    required this.places,
    this.selectedPlaceId,
    this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final selectedPlace = _getSelectedPlace();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(24),
        color: AppColors.white,
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (selectedPlace != null)
            PlaceCard(
              place: selectedPlace,
              onDirectionsTap: onDirectionsTap != null ? () => onDirectionsTap!(selectedPlace) : null,
            )
          else
            _buildPlacesSummary(),
        ],
      ),
    );
  }

  Widget _buildPlacesSummary() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: smoothDecoration(
        cornerRadius: 12,
        color: AppColors.primary.withValues(alpha: 0.08),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppIcons.locationPinIcon,
            color: AppColors.primary,
            colorBlendMode: BlendMode.srcIn,
            height: 20,
            width: 20,
          ),
          const SizedBox(width: 8),
          Text(
            '${places.length} ${AppStrings.petServicesFoundNearby}',
            style: AppTextStyles.mediumStyle500(
              fontSize: 14,
              fontColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  PlacesModel? _getSelectedPlace() {
    if (selectedPlaceId == null || places.isEmpty) {
      return null;
    }

    try {
      return places.firstWhere((p) => p.placeId == selectedPlaceId);
    } catch (e) {
      return null;
    }
  }
}
