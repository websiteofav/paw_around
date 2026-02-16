import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/url_utils.dart';

/// Owner section: modern card with owner identity and tappable phone numbers.
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

  bool get _hasAnyData =>
      (ownerName != null && ownerName!.trim().isNotEmpty) ||
      (ownerPhone != null && ownerPhone!.trim().isNotEmpty) ||
      (alternatePhone != null && alternatePhone!.trim().isNotEmpty);

  String? get _initials {
    final name = ownerName?.trim();
    if (name == null || name.isEmpty) return null;
    final parts = name.split(RegExp(r'\\s+'));
    if (parts.isEmpty) return null;
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second =
        parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    final value = (first + second).trim();
    return value.isEmpty ? null : value.toUpperCase();
  }

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
      child: _hasAnyData ? _buildContentWithData() : _buildEmptyState(),
    );
  }

  Widget _buildContentWithData() {
    final displayName = ownerName != null && ownerName!.trim().isNotEmpty
        ? ownerName!.trim()
        : AppStrings.owner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header: avatar + name + primary owner label
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _OwnerAvatar(initials: _initials),
            AppSpacing.horizontal12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: AppTextStyles.semiBoldStyle600(
                      fontSize: 16,
                      fontColor: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.vertical4,
                  Text(
                    AppStrings.primaryOwner,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 12,
                      fontColor: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        AppSpacing.vertical16,
        // Primary phone
        if (ownerPhone != null && ownerPhone!.trim().isNotEmpty)
          _PrimaryPhoneRow(phone: ownerPhone!.trim()),
        if (ownerPhone != null &&
            ownerPhone!.trim().isNotEmpty &&
            alternatePhone != null &&
            alternatePhone!.trim().isNotEmpty)
          AppSpacing.vertical16,
        // Alternate phone
        if (alternatePhone != null && alternatePhone!.trim().isNotEmpty) ...[
          Text(
            AppStrings.alternateContact,
            style: AppTextStyles.mediumStyle500(
              fontSize: 12,
              fontColor: AppColors.textSecondary,
            ),
          ),
          AppSpacing.vertical8,
          _AlternatePhoneRow(phone: alternatePhone!.trim()),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.info_outline,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            AppStrings.contactViaPawAround,
            style: AppTextStyles.regularStyle400(
              fontSize: 14,
              fontColor: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerAvatar extends StatelessWidget {
  final String? initials;

  const _OwnerAvatar({this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.iconBgLight,
        borderRadius: AppBorderRadius.full,
      ),
      child: Center(
        child: initials != null
            ? Text(
                initials!,
                style: AppTextStyles.semiBoldStyle600(
                  fontSize: 16,
                  fontColor: AppColors.primary,
                ),
              )
            : const Icon(
                Icons.person_outline,
                size: 22,
                color: AppColors.primary,
              ),
      ),
    );
  }
}

class _PrimaryPhoneRow extends StatelessWidget {
  final String phone;

  const _PrimaryPhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    final cleanPhone = phone.replaceAll(' ', '');
    return InkWell(
      onTap: () => UrlUtils.launch('tel:$cleanPhone'),
      borderRadius: AppBorderRadius.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    phone,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 14,
                      fontColor: AppColors.primary,
                    ),
                  ),
                  AppSpacing.vertical4,
                  Text(
                    AppStrings.publicPetOwnerTapToCall,
                    style: AppTextStyles.regularStyle400(
                      fontSize: 12,
                      fontColor: AppColors.textSecondary,
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
}

class _AlternatePhoneRow extends StatelessWidget {
  final String phone;

  const _AlternatePhoneRow({required this.phone});

  @override
  Widget build(BuildContext context) {
    final cleanPhone = phone.replaceAll(' ', '');
    return InkWell(
      onTap: () => UrlUtils.launch('tel:$cleanPhone'),
      borderRadius: AppBorderRadius.sm,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.phone_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                phone,
                style: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
