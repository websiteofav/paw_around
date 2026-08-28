import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

class PostDetailLocationSection extends StatelessWidget {
  final LostFoundPost post;

  const PostDetailLocationSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.location,
            style: AppTextStyles.interBoldStyle700(
                fontSize: 18, fontColor: AppColors.grey1100)),
        const SizedBox(height: 12),
        Container(
          decoration: smoothDecoration(
            cornerRadius: 20,
            shadows: [
              BoxShadow(
                  color: AppColors.shadowOverlay.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: ClipSmoothRect(
            radius: AppSmoothRadius.custom(19),
            child: SizedBox(
              height: 180,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(post.latitude, post.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('post_location'),
                    position: LatLng(post.latitude, post.longitude),
                  ),
                },
                zoomControlsEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
