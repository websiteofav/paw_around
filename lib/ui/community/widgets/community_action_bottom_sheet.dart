import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/community/lost_found_post.dart';

class CommunityActionBottomSheet extends StatelessWidget {
  const CommunityActionBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const CommunityActionBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: smoothDecoration(
        borderRadius: AppSmoothRadius.topOnly(24),
        color: AppColors.surface,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: smoothDecoration(
                cornerRadius: 2,
                color: AppColors.border,
              ),
            ),
            // Title
            Text(
              AppStrings.whatWouldYouLikeToShare,
              style: AppTextStyles.semiBoldStyle600(
                fontSize: 20,
                fontColor: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Action options
            _buildActionOption(
              context: context,
              icon: Icons.search,
              iconColor: AppColors.error,
              title: AppStrings.reportLostPet,
              subtitle: AppStrings.reportLostPetDescription,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.createPost,
                  extra: PostType.lost,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionOption(
              context: context,
              icon: Icons.favorite,
              iconColor: AppColors.success,
              title: AppStrings.reportFoundPet,
              subtitle: AppStrings.reportFoundPetDescription,
              onTap: () {
                Navigator.pop(context);
                context.push(
                  AppRoutes.createPost,
                  extra: PostType.found,
                );
              },
            ),
            const SizedBox(height: 16),
            _buildActionOption(
              context: context,
              icon: Icons.auto_awesome,
              iconColor: AppColors.primary,
              title: AppStrings.shareMoment,
              subtitle: AppStrings.shareMomentDescription,
              onTap: () {
                Navigator.pop(context);
                context.pushNamed(AppRoutes.createMoment);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActionOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: smoothDecoration(
            cornerRadius: 12,
            color: AppColors.white,
            side: const BorderSide(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: smoothDecoration(
                  cornerRadius: 12,
                  color: iconColor.withValues(alpha: 0.1),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.semiBoldStyle600(
                        fontSize: 16,
                        fontColor: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.regularStyle400(
                        fontSize: 14,
                        fontColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
