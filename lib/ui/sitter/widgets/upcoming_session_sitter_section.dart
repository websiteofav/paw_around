import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/sitters/booking_model.dart';

/// Shows the matched sitter's name, role, rating, and Call/Message actions.
class UpcomingSessionSitterSection extends StatelessWidget {
  final BookingModel booking;

  const UpcomingSessionSitterSection({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.iconBgLight,
              child: Icon(Icons.person, color: AppColors.primaryDark),
            ),
            AppSpacing.horizontal12,
            Expanded(child: _buildAssignedInfo()),
          ],
        ),
        AppSpacing.vertical12,
        _buildActionPills(),
      ],
    );
  }

  Widget _buildAssignedInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          booking.professionalName,
          style: AppTextStyles.interBoldStyle700(
              fontSize: 16, fontColor: AppColors.grey1000),
        ),
        Row(
          spacing: 4,
          children: [
            Text(
              booking.professionalRole,
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 12, fontColor: AppColors.grey600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.star, size: 16, color: AppColors.ratingColor),
            Text(
              '${booking.professionalRating.toStringAsFixed(2)} (${booking.professionalReviewCount} ${AppStrings.reviewsSuffix})',
              style: AppTextStyles.interRegularStyle400(
                  fontSize: 12, fontColor: AppColors.grey600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionPills() {
    return const Row(
      children: [
        _ActionPill(icon: Icons.call_outlined, label: AppStrings.call),
        AppSpacing.horizontal12,
        _ActionPill(icon: Icons.chat_bubble_outline, label: AppStrings.message),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(icon, size: 18, color: AppColors.secondaryCTA),
      label: Text(
        label,
        style: AppTextStyles.interBoldStyle700(
            fontSize: 14, fontColor: AppColors.secondaryCTA),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.secondaryCTA),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        disabledForegroundColor: AppColors.secondaryCTA,
      ),
    );
  }
}
