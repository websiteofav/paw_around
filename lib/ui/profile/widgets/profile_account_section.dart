import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';

class ProfileAccountSection extends StatelessWidget {
  final VoidCallback onAccountSettingsTap;
  final VoidCallback onNotificationsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onHelpTap;
  final VoidCallback onDeleteAccountTap;

  const ProfileAccountSection({
    super.key,
    required this.onAccountSettingsTap,
    required this.onNotificationsTap,
    required this.onPrivacyTap,
    required this.onHelpTap,
    required this.onDeleteAccountTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildItem(
            icon: Icons.settings_outlined,
            title: AppStrings.accountSettings,
            onTap: onAccountSettingsTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            icon: Icons.notifications_outlined,
            title: AppStrings.notifications,
            onTap: onNotificationsTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            icon: Icons.shield_outlined,
            title: AppStrings.privacyAndSecurity,
            onTap: onPrivacyTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            icon: Icons.help_outline,
            title: AppStrings.helpAndSupport,
            onTap: onHelpTap,
          ),
          const Divider(height: 1, color: AppColors.border),
          _buildItem(
            icon: Icons.delete_outline,
            title: AppStrings.deleteAccount,
            onTap: onDeleteAccountTap,
            isDanger: true,
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    final color = isDanger ? AppColors.error : AppColors.primary;

    return ScaleButton(
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDanger ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDanger ? AppColors.error.withValues(alpha: 0.5) : AppColors.textSecondary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
