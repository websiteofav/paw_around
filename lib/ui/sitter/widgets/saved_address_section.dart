import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/sitter/widgets/saved_address_list_item.dart';

/// "Saved Address" header + list, shown on the Sitter screen once the user
/// has at least one saved address.
class SavedAddressSection extends StatelessWidget {
  final List<AddressModel> addresses;

  const SavedAddressSection({super.key, required this.addresses});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.savedAddress,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 14,
            fontColor: AppColors.textSecondary,
          ),
        ),
        AppSpacing.vertical12,
        for (var i = 0; i < addresses.length; i++) ...[
          SavedAddressListItem(address: addresses[i]),
          if (i != addresses.length - 1) ...[
            AppSpacing.vertical16,
            const Divider(color: AppColors.border, height: 1),
            AppSpacing.vertical16,
          ],
        ],
      ],
    );
  }
}
