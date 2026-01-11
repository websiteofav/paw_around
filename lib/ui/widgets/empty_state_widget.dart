import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_spacing.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';

/// A reusable empty state widget with optional Lottie animation or icon,
/// title, subtitle, and call-to-action button.
class EmptyStateWidget extends StatelessWidget {
  /// Path to a Lottie animation file (e.g., 'assets/lottie/add_pet.json')
  final String? lottieAsset;

  /// Icon to display if no Lottie asset is provided
  final IconData? icon;

  /// Icon color (defaults to primary)
  final Color? iconColor;

  /// Background color for the icon container
  final Color? iconBackgroundColor;

  /// Main title text
  final String title;

  /// Descriptive subtitle text
  final String? subtitle;

  /// Text for the CTA button
  final String? actionText;

  /// Callback when CTA button is pressed
  final VoidCallback? onAction;

  /// Optional secondary action text
  final String? secondaryActionText;

  /// Callback for secondary action
  final VoidCallback? onSecondaryAction;

  /// Size of the Lottie animation or icon container
  final double illustrationSize;

  /// Whether to wrap in a card container
  final bool showCard;

  /// Optional list of hint items to display
  final List<EmptyStateHint>? hints;

  const EmptyStateWidget({
    super.key,
    this.lottieAsset,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
    this.secondaryActionText,
    this.onSecondaryAction,
    this.illustrationSize = 120.0,
    this.showCard = true,
    this.hints,
  }) : assert(
          lottieAsset != null || icon != null,
          'Either lottieAsset or icon must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Illustration (Lottie or Icon)
        _buildIllustration(),
        AppSpacing.vertical24,

        // Title
        Text(
          title,
          style: AppTextStyles.semiBoldStyle600(
            fontSize: 20,
            fontColor: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        // Subtitle
        if (subtitle != null) ...[
          AppSpacing.vertical10,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.space16),
            child: Text(
              subtitle!,
              style: AppTextStyles.regularStyle400(
                fontSize: 14,
                fontColor: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Hints
        if (hints != null && hints!.isNotEmpty) ...[
          AppSpacing.vertical24,
          ...hints!.map((hint) => _buildHintRow(hint)),
        ],

        // CTA Button
        if (actionText != null && onAction != null) ...[
          AppSpacing.vertical28,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.space24),
            child: CommonButton(
              text: actionText!,
              onPressed: onAction,
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
              icon: Icons.add_circle_outline,
            ),
          ),
        ],

        // Secondary Action
        if (secondaryActionText != null && onSecondaryAction != null) ...[
          AppSpacing.vertical12,
          TextButton(
            onPressed: onSecondaryAction,
            child: Text(
              secondaryActionText!,
              style: AppTextStyles.mediumStyle500(
                fontSize: 14,
                fontColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ],
    );

    if (!showCard) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: AppEdgeInsets.allLarge,
          child: content,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        width: double.infinity,
        margin: AppEdgeInsets.allMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.space28,
          vertical: AppConstants.space40,
        ),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowOverlay.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: content,
      ),
    );
  }

  Widget _buildIllustration() {
    if (lottieAsset != null) {
      return SizedBox(
        width: illustrationSize,
        height: illustrationSize,
        child: lottieAsset!.startsWith('http')
            ? Lottie.network(
                lottieAsset!,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  return _buildIconFallback();
                },
              )
            : Lottie.asset(
                lottieAsset!,
                fit: BoxFit.contain,
                repeat: true,
                errorBuilder: (context, error, stackTrace) {
                  return _buildIconFallback();
                },
              ),
      );
    }

    return _buildIconFallback();
  }

  Widget _buildIconFallback() {
    return Container(
      width: illustrationSize,
      height: illustrationSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            (iconBackgroundColor ?? AppColors.primary).withValues(alpha: 0.15),
            (iconBackgroundColor ?? AppColors.primaryLight).withValues(alpha: 0.1),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: illustrationSize * 0.42,
        color: iconColor ?? AppColors.primary.withValues(alpha: 0.8),
      ),
    );
  }

  Widget _buildHintRow(EmptyStateHint hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space12),
      child: Row(
        children: [
          Icon(
            hint.icon,
            size: 18,
            color: AppColors.primary,
          ),
          AppSpacing.horizontal10,
          Expanded(
            child: Text(
              hint.text,
              style: AppTextStyles.regularStyle400(
                fontSize: 13,
                fontColor: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hint item for the empty state widget
class EmptyStateHint {
  final IconData icon;
  final String text;

  const EmptyStateHint({
    required this.icon,
    required this.text,
  });
}
