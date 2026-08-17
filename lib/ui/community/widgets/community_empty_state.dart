import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_constants.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/common_button.dart';
import 'package:paw_around/ui/widgets/info_banner.dart';

/// Rich empty state used across the Paw Circle tabs (Lost & Found, Moments):
/// title, fading illustration, a checklist card with a CTA, and a tip banner.
class CommunityEmptyState extends StatelessWidget {
  final String title;
  final List<String> checklistItems;
  final String ctaText;
  final VoidCallback onCta;
  final String? tipText;
  final String imagePath;

  const CommunityEmptyState({
    super.key,
    required this.title,
    required this.checklistItems,
    required this.ctaText,
    required this.onCta,
    this.tipText,
    this.imagePath = AppIcons.emptyStateDogIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.boldStyle700(
                fontSize: 24, fontColor: AppColors.grey1000),
          ),
          const SizedBox(height: 24),
          Center(child: _buildImage()),
          const SizedBox(height: 24),
          _buildChecklistCard(),
          if (tipText != null) ...[
            const SizedBox(height: 16),
            InfoBanner(text: tipText!),
          ],
        ],
      ),
    );
  }

  Widget _buildImage() {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.65, 1.0],
        colors: [Colors.white, Colors.transparent],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: Image.asset(
        imagePath,
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: smoothDecoration(
        cornerRadius: AppConstants.radiusLG,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in checklistItems) _buildChecklistRow(item),
          const SizedBox(height: 4),
          CommonButton(
            text: ctaText,
            onPressed: onCta,
            customTextColor: AppColors.grey1000,
            textStyle: AppTextStyles.interBoldStyle700(
                fontSize: 16, fontColor: AppColors.grey1000),
            borderRadius: AppConstants.radiusFull,
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.navColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check, size: 14, color: AppColors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 15, fontColor: AppColors.grey700),
            ),
          ),
        ],
      ),
    );
  }
}
