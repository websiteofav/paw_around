import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          if (selectedPlace != null)
            PlaceCard(
              place: selectedPlace,
              onDirectionsTap: onDirectionsTap != null ? () => onDirectionsTap!(selectedPlace) : null,
            )
          else
            Text(
              '${places.length} ${AppStrings.petServicesFoundNearby}',
              style: AppTextStyles.bodyText(),
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
