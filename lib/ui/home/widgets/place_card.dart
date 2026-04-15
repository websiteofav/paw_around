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
        height: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: place.photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CachedNetworkImage(
                        imageUrl: place.photoUrl!,
                        placeholder: (context, url) => _buildPlaceholder(),
                        errorWidget: (context, url, error) =>
                            _buildFallbackIcon(),
                        fit: BoxFit.cover,
                        width: 116,
                        height: 116,
                      ),
                    )
                  : _buildFallbackIcon(),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: AppTextStyles.interBoldStyle700(
                        fontSize: 16, fontColor: AppColors.grey1000),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    place.address,
                    style: AppTextStyles.interRegularStyle400(
                        fontSize: 12, fontColor: AppColors.grey600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _buildRatingRow(),
                  const SizedBox(height: 10),
                  // Location button
                  ScaleButton(
                    onPressed: onDirectionsTap,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.grey1000,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(AppStrings.location,
                              style: AppTextStyles.interMediumStyle500(
                                  fontSize: 14, fontColor: AppColors.white)),
                          const SizedBox(width: 8),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                                color: AppColors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.chevron_right,
                                size: 14, color: AppColors.grey1000),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (place.rating != null) ...[
          const Icon(Icons.star_rounded,
              color: AppColors.ratingColor, size: 16),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${place.rating}',
              style: AppTextStyles.mediumStyle500(
                  fontSize: 13, fontColor: AppColors.grey1000),
            ),
          ),
          if (place.userRatingsTotal != null)
            Text(
              ' (${place.userRatingsTotal})',
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 12, fontColor: AppColors.grey600),
            ),
          const SizedBox(width: 10),
        ],
        //   if (place.isOpen != null) _buildOpenStatusBadge(),
      ],
    );
  }

  Widget _buildOpenStatusBadge() {
    final bool isOpen = place.isOpen!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? AppColors.success.withValues(alpha: 0.15)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOpen ? AppStrings.open : AppStrings.closed,
        style: AppTextStyles.semiBoldStyle600(
          fontSize: 11,
          fontColor: isOpen ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 88,
      height: 88,
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
      width: 116,
      height: 116,
      decoration: BoxDecoration(
        color: _getTypeColor(place.types),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        _getTypeIcon(place.types),
        color: AppColors.serviceIconColor,
        size: 32,
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
