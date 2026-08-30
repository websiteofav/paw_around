import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/addresses/address_model.dart';
import 'package:paw_around/ui/sitter/widgets/book_sitters_location_card.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

/// Location card + "Add new Address" / "Switch address" actions on the
/// Book Sitters screen.
class BookSittersLocationSection extends StatelessWidget {
  final AddressModel selectedAddress;
  final List<AddressModel> addresses;
  final VoidCallback onEdit;
  final VoidCallback onAddNewAddress;
  final ValueChanged<AddressModel> onSwitchAddress;

  const BookSittersLocationSection({
    super.key,
    required this.selectedAddress,
    required this.addresses,
    required this.onEdit,
    required this.onAddNewAddress,
    required this.onSwitchAddress,
  });

  void _showAddressPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _AddressPickerSheet(
        addresses: addresses,
        selectedAddressId: selectedAddress.id,
        onSelect: (address) {
          Navigator.pop(sheetContext);
          onSwitchAddress(address);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookSittersLocationCard(
          address: selectedAddress,
          onEdit: onEdit,
          onSwitchAddress: addresses.length > 1 ? () => _showAddressPicker(context) : null,
        ),
        AppSpacing.vertical12,
        ScaleButton(
          onPressed: onAddNewAddress,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline, size: 16, color: AppColors.secondaryCTA),
              AppSpacing.horizontal4,
              Text(
                AppStrings.addNewAddress,
                style: AppTextStyles.interSemiBoldStyle600(
                  fontSize: 13,
                  fontColor: AppColors.secondaryCTA,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AddressPickerSheet extends StatelessWidget {
  final List<AddressModel> addresses;
  final String selectedAddressId;
  final ValueChanged<AddressModel> onSelect;

  const _AddressPickerSheet({
    required this.addresses,
    required this.selectedAddressId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(24),
        color: AppColors.white,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: smoothDecoration(
                  cornerRadius: 2,
                  color: AppColors.border,
                ),
              ),
            ),
            Text(
              AppStrings.selectASavedAddress,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 16,
                fontColor: AppColors.grey1000,
              ),
            ),
            AppSpacing.vertical16,
            for (final address in addresses) ...[
              _AddressPickerRow(
                address: address,
                isSelected: address.id == selectedAddressId,
                onTap: () => onSelect(address),
              ),
              AppSpacing.vertical12,
            ],
          ],
        ),
      ),
    );
  }
}

class _AddressPickerRow extends StatelessWidget {
  final AddressModel address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressPickerRow({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleButton(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: smoothDecoration(
          cornerRadius: 14,
          color: isSelected ? AppColors.background3 : AppColors.background,
          side: BorderSide(
            color: isSelected ? AppColors.secondaryCTA : AppColors.grey100,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.boldStyle700(
                      fontSize: 14,
                      fontColor: AppColors.grey1000,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.fullAddress,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 12,
                      fontColor: AppColors.grey1000,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.secondaryCTA, size: 20),
          ],
        ),
      ),
    );
  }
}
