import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// "I Found This Pet" CTA; when tapped shows share location + message. Only when [pet.isLost].
class PublicPetFoundSection extends StatefulWidget {
  final PetModel pet;

  const PublicPetFoundSection({super.key, required this.pet});

  @override
  State<PublicPetFoundSection> createState() => _PublicPetFoundSectionState();
}

class _PublicPetFoundSectionState extends State<PublicPetFoundSection> {
  bool _expanded = false;
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.pet.isLost) return const SizedBox.shrink();

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonButton(
            text: AppStrings.iFoundThisPet,
            icon: Icons.location_on_outlined,
            onPressed: () => setState(() => _expanded = !_expanded),
            variant: ButtonVariant.primary,
            customColor: AppColors.cardBlueIcon,
            size: ButtonSize.large,
            isFullWidth: true,
          ),
          if (_expanded) ...[
            AppSpacing.vertical20,
            Text(
              AppStrings.youFoundThisPetShareLocation,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
              ),
            ),
            AppSpacing.vertical12,
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.sendMessageToOwner,
                hintStyle: AppTextStyles.regularStyle400(
                  fontSize: 14,
                  fontColor: AppColors.textLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppBorderRadius.sm,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.sm,
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
