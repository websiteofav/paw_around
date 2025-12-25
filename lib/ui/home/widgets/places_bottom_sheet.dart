import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
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
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.primary,
            size: 20,
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
