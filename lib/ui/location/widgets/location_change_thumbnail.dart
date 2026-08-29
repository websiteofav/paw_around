import 'dart:typed_data';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// Small square "Change" affordance next to the Area field on the Location
/// Details screen — taps back to the Pick Location (map) screen. Shows a
/// snapshot of the confirmed map view as its background when available.
class LocationChangeThumbnail extends StatelessWidget {
  final VoidCallback onTap;
  final Uint8List? mapSnapshot;

  const LocationChangeThumbnail({
    super.key,
    required this.onTap,
    this.mapSnapshot,
  });

  static const double _size = 100;

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        width: _size,
        height: _size,
        decoration: smoothDecoration(
          cornerRadius: 12,
          color: AppColors.background,
          side: const BorderSide(color: AppColors.neutral300),
          image: mapSnapshot != null
              ? DecorationImage(
                  image: MemoryImage(mapSnapshot!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipSmoothRect(
          radius: AppSmoothRadius.custom(12),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Legibility scrim so the pin + label read clearly over any
              // map snapshot underneath.
              if (mapSnapshot != null) Container(color: AppColors.white.withValues(alpha: 0.55)),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(AppIcons.mapPinConfirmIcon, width: 32, height: 36),
                  AppSpacing.vertical4,
                  Text(
                    AppStrings.changeLabel,
                    style: AppTextStyles.semiBoldStyle600(
                      fontSize: 13,
                      fontColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
