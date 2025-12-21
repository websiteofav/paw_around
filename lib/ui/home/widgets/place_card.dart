import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/places/places_model.dart';

class PlaceCard extends StatelessWidget {
  final PlacesModel place;
  final VoidCallback? onDirectionsTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getTypeColor(place.types),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getTypeIcon(place.types),
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: AppTextStyles.cardTitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  place.address,
                  style: AppTextStyles.cardSubtitle(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                _buildRatingRow(),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDirectionsTap,
            child: const Icon(Icons.directions, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        if (place.rating != null) ...[
          const Icon(Icons.star, color: Colors.amber, size: 16),
          const SizedBox(width: 4),
          Text(
            '${place.rating}',
            style: AppTextStyles.cardSubtitle(fontWeight: FontWeight.w500),
          ),
          if (place.userRatingsTotal != null)
            Text(
              ' (${place.userRatingsTotal})',
              style: AppTextStyles.cardSubtitle(),
            ),
          const SizedBox(width: 12),
        ],
        if (place.isOpen != null) _buildOpenStatusBadge(),
      ],
    );
  }

  Widget _buildOpenStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: place.isOpen! ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        place.isOpen! ? AppStrings.open : AppStrings.closed,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getTypeColor(List<String> types) {
    if (types.contains('veterinary_care')) {
      return Colors.red[400]!;
    } else if (types.contains('pet_store')) {
      return Colors.blue[400]!;
    }
    return Colors.green[400]!;
  }

  IconData _getTypeIcon(List<String> types) {
    if (types.contains('veterinary_care')) {
      return Icons.local_hospital;
    } else if (types.contains('pet_store')) {
      return Icons.store;
    }
    return Icons.content_cut;
  }
}
