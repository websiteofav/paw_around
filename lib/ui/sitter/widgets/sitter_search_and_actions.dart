import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_location_action_card.dart';
import 'package:paw_around/ui/sitter/widgets/sitter_search_location_field.dart';

/// Search pill + "Use current location"/"Add new Address" card row shared
/// by both the empty and populated states of [SitterScreen].
class SitterSearchAndActions extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onAddNewAddress;

  const SitterSearchAndActions({
    super.key,
    required this.onSearchTap,
    required this.onUseCurrentLocation,
    required this.onAddNewAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SitterSearchLocationField(onTap: onSearchTap),
        AppSpacing.vertical16,
        Row(
          children: [
            Expanded(
              child: SitterLocationActionCard(
                icon: Image.asset(
                  AppIcons.gpsOutlineIcon,
                  color: AppColors.secondaryCTA,
                  colorBlendMode: BlendMode.srcIn,
                  height: 24,
                  width: 24,
                ),
                label: AppStrings.useCurrentLocation,
                onTap: onUseCurrentLocation,
              ),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: SitterLocationActionCard(
                icon: Image.asset(
                  AppIcons.addSquareIcon,
                  color: AppColors.secondaryCTA,
                  colorBlendMode: BlendMode.srcIn,
                  height: 24,
                  width: 24,
                ),
                label: AppStrings.addNewAddress,
                onTap: onAddNewAddress,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
