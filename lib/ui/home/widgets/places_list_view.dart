import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/home/widgets/place_card.dart';
import 'package:paw_around/ui/widgets/animated_card.dart';
import 'package:paw_around/utils/url_utils.dart';

class PlacesListView extends StatelessWidget {
  final List<PlacesModel> places;
  final Function(PlacesModel)? onDirectionsTap;
  final Function(PlacesModel)? onPlaceTap;

  const PlacesListView({
    super.key,
    required this.places,
    this.onDirectionsTap,
    this.onPlaceTap,
  });

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      itemBuilder: (context, index) {
        return AnimatedCard(
          index: index,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PlaceCard(
              place: places[index],
              onTap: onPlaceTap != null ? () => onPlaceTap!(places[index]) : null,
              onDirectionsTap: () => UrlUtils.launch(places[index].directionsUrl),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            AppStrings.noServicesNearby,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 18,
              fontColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.tryDifferentLocation,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
