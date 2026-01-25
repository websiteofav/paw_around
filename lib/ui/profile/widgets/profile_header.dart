import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/ui/widgets/scale_button.dart';
import 'package:paw_around/utils/utils.dart';

class ProfileHeader extends StatelessWidget {
  final VoidCallback? onEditTap;

  const ProfileHeader({
    super.key,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use StreamBuilder to listen to user changes (including profile updates)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final String displayName =
            (user?.displayName).orDefault(AppStrings.petParent);
        final String? photoUrl = user?.photoURL;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular avatar with gradient
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: photoUrl != null
                      ? Image.network(photoUrl, fit: BoxFit.cover)
                      : const Icon(
                          Icons.person,
                          color: AppColors.profileHeaderBg,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(width: 16),

              // User name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.semiBoldStyle600(
                          fontSize: 18, fontColor: AppColors.textPrimary),
                    ),
                    if (user?.email != null || user?.phoneNumber != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? user?.phoneNumber ?? '',
                        style: AppTextStyles.regularStyle400(
                            fontSize: 13, fontColor: AppColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              // Edit button
              ScaleButton(
                onPressed: onEditTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppStrings.edit,
                        style: AppTextStyles.mediumStyle500(
                            fontSize: 14, fontColor: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
