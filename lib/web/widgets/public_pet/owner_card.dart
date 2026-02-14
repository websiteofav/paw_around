import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/url_utils.dart';

/// Owner section: name, primary phone (tappable), optional alternate.
class PublicPetOwnerCard extends StatelessWidget {
  final String? ownerName;
  final String? ownerPhone;
  final String? alternatePhone;

  const PublicPetOwnerCard({
    super.key,
    this.ownerName,
    this.ownerPhone,
    this.alternatePhone,
  });

  bool get hasAnyData =>
      (ownerName != null && ownerName!.isNotEmpty) ||
      (ownerPhone != null && ownerPhone!.isNotEmpty) ||
      (alternatePhone != null && alternatePhone!.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppEdgeInsets.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppBorderRadius.lg,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppStrings.owner,
            style: AppTextStyles.semiBoldStyle600(
              fontSize: 18,
              fontColor: AppColors.textPrimary,
            ),
          ),
          AppSpacing.vertical16,
          if (hasAnyData) ...[
            if (ownerName != null && ownerName!.isNotEmpty)
              _OwnerRow(icon: Icons.person_outline, label: ownerName!),
            if (ownerPhone != null && ownerPhone!.isNotEmpty)
              _OwnerTapRow(
                icon: Icons.phone_outlined,
                label: ownerPhone!,
                onTap: () =>
                    UrlUtils.launch('tel:${ownerPhone!.replaceAll(' ', '')}'),
              ),
            if (alternatePhone != null && alternatePhone!.isNotEmpty) ...[
              AppSpacing.vertical8,
              Text(
                AppStrings.alternateContact,
                style: AppTextStyles.mediumStyle500(
                  fontSize: 12,
                  fontColor: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              _OwnerTapRow(
                icon: Icons.phone_outlined,
                label: alternatePhone!,
                onTap: () => UrlUtils.launch(
                    'tel:${alternatePhone!.replaceAll(' ', '')}'),
              ),
            ],
          ] else
            Text(
              AppStrings.contactViaPawAround,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _OwnerRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _OwnerRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OwnerTapRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OwnerTapRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.sm,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
