import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/places/places_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class PlaceCard extends StatelessWidget {
  final PlacesModel place;
  final VoidCallback? onDirectionsTap;
  final VoidCallback? onTap;

  const PlaceCard({
    super.key,
    required this.place,
    this.onDirectionsTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getTypeColor(place.types),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: place.photoUrl != null
                    ? CachedNetworkImage(
                        imageUrl: place.photoUrl!,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) => _buildFallbackIcon(),
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      )
                    : _buildFallbackIcon(),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.semiBoldStyle600(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    place.address,
                    style: AppTextStyles.regularStyle400(fontSize: 13, fontColor: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildRatingRow(),
                ],
              ),
            ),
            ScaleButton(
              onPressed: onDirectionsTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.directions,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      children: [
        if (place.rating != null) ...[
          const Icon(Icons.star_rounded, color: AppColors.ratingColor, size: 16),
          const SizedBox(width: 4),
          Text(
            '${place.rating}',
            style: AppTextStyles.mediumStyle500(fontSize: 13, fontColor: AppColors.textPrimary),
          ),
          if (place.userRatingsTotal != null)
            Text(
              ' (${place.userRatingsTotal})',
              style: AppTextStyles.regularStyle400(fontSize: 12, fontColor: AppColors.textSecondary),
            ),
          const SizedBox(width: 10),
        ],
        if (place.isOpen != null) _buildOpenStatusBadge(),
      ],
    );
  }

  Widget _buildOpenStatusBadge() {
    final bool isOpen = place.isOpen!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? AppStrings.open : AppStrings.closed,
        style: TextStyle(
          color: isOpen ? AppColors.success : AppColors.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: _getTypeColor(place.types),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 56,
      height: 56,
      color: _getTypeColor(place.types),
      child: Icon(
        _getTypeIcon(place.types),
        color: AppColors.serviceIconColor,
        size: 28,
      ),
    );
  }

  Color _getTypeColor(List<String> types) {
    if (types.contains('veterinary_care')) {
      return AppColors.vetServiceBg;
    } else if (types.contains('pet_store')) {
      return AppColors.petStoreBg;
    }
    return AppColors.groomingServiceBg;
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
