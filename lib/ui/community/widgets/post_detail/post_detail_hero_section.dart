import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

/// Full-bleed hero photo with a top-to-transparent gradient for the back
/// button's legibility. The identity card is layered on top of this by the
/// screen (via Stack + Positioned) so it can overlap the hero's bottom edge.
class PostDetailHeroSection extends StatelessWidget {
  final LostFoundPost post;
  final String heroTag;

  const PostDetailHeroSection(
      {super.key, required this.post, required this.heroTag});

  static const double height = 320;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(tag: heroTag, child: _buildImage()),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.shadowOverlay.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.4],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final imagePath = post.imagePath;
    if (imagePath != null && imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.surface,
          child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.iconBgLight,
      child: Center(
        child: Icon(Icons.pets,
            size: 64, color: AppColors.primary.withValues(alpha: 0.3)),
      ),
    );
  }
}
