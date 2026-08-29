import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// One row in the Sitter screen's "Saved Address" list.
class SavedAddressListItem extends StatelessWidget {
  final AddressModel address;

  const SavedAddressListItem({super.key, required this.address});

  void _onTap() {
    // TODO: navigate to sitter search results for this address, once that
    // screen exists.
  }

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: _onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: smoothDecoration(
              cornerRadius: 10,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            padding: const EdgeInsets.all(9),
            child: Image.asset(
              AppIcons.locationPinIcon,
              color: AppColors.primary,
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
                  style: AppTextStyles.semiBoldStyle600(
                    fontSize: 15,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address.formattedAddress,
                  style: AppTextStyles.regularStyle400(
                    fontSize: 13,
                    fontColor: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
