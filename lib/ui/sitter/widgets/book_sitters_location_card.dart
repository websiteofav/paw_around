import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';

/// "Location" card on the Book Sitters screen — the address this booking is
/// for, with an edit affordance back to the Pick Location map screen.
class BookSittersLocationCard extends StatelessWidget {
  final AddressModel address;
  final VoidCallback onEdit;

  /// Opens the saved-address picker — null (and hidden) when there's only
  /// one address to show.
  final VoidCallback? onSwitchAddress;

  const BookSittersLocationCard({
    super.key,
    required this.address,
    required this.onEdit,
    this.onSwitchAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.locationLabel,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: smoothDecoration(
                cornerRadius: 10,
                color: AppColors.background3,
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                AppIcons.locationPinBoldIcon,
                color: AppColors.black,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.interBoldStyle700(
                      fontSize: 16,
                      fontColor: AppColors.grey1000,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.fullAddress,
                    style: AppTextStyles.interRegularStyle400(
                      fontSize: 12,
                      fontColor: AppColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.horizontal12,
            GestureDetector(
              onTap: onEdit,
              child: SvgPicture.asset(
                AppIcons.editIcon,
                height: 20,
                colorFilter: const ColorFilter.mode(AppColors.secondaryCTA, BlendMode.srcIn),
              ),
            ),
            if (onSwitchAddress != null) ...[
              AppSpacing.horizontal12,
              GestureDetector(
                onTap: onSwitchAddress,
                child: const Icon(
                  Icons.unfold_more,
                  size: 20,
                  color: AppColors.grey600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
