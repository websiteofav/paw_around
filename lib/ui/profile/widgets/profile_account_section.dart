import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class ProfileAccountSection extends StatelessWidget {
  final VoidCallback onMyPostsTap;
  final VoidCallback onAccountSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;
  final VoidCallback onHelpTap;
  final VoidCallback onDeleteAccountTap;

  const ProfileAccountSection({
    super.key,
    required this.onMyPostsTap,
    required this.onAccountSettingsTap,
    required this.onNotificationsTap,
    required this.onPrivacyTap,
    required this.onTermsTap,
    required this.onHelpTap,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: smoothDecoration(
        cornerRadius: 36,
        color: AppColors.white,
        side: const BorderSide(color: AppColors.border),
        shadows: [
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.05),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: AppColors.shadowOverlay.withValues(alpha: 0.04),
            blurRadius: 13,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem(
            assetPath: AppIcons.myPostsIcon,
            title: AppStrings.myPosts,
            onTap: onMyPostsTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.settingsIcon,
            title: AppStrings.accountSettings,
            onTap: onAccountSettingsTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.notificationIcon,
            title: AppStrings.notifications,
            onTap: onNotificationsTap,
            isPng: true,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.privacyIcon,
            title: AppStrings.privacyPolicy,
            onTap: onPrivacyTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.termsServiceIcon,
            title: AppStrings.termsOfService,
            onTap: onTermsTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.helpSupportIcon,
            title: AppStrings.helpAndSupport,
            onTap: onHelpTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            assetPath: AppIcons.deleteAccountIcon,
            title: AppStrings.deleteAccount,
            onTap: onDeleteAccountTap,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required String assetPath,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
    bool isPng = false,
  }) {
    return ScaleButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Center(
              child: isPng
                  ? Image.asset(assetPath,
                      width: 20,
                      height: 20,
                      color:
                          isDanger ? AppColors.error : AppColors.secondaryCTA)
                  : SvgPicture.asset(assetPath,
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                          isDanger ? AppColors.error : AppColors.secondaryCTA,
                          BlendMode.srcIn)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.regularStyle400(
                  fontSize: 16,
                  fontColor: isDanger ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDanger ? AppColors.error : AppColors.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
