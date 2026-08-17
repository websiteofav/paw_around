import 'package:figma_squircle/figma_squircle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/utils.dart';

/// Hero photo area only (back button overlaid).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        return _HeroPhotoArea(photoUrl: user?.photoURL);
      },
    );
  }
}

/// Name + contact row rendered flat inside the white content sheet.
class ProfileNameCard extends StatelessWidget {
  final VoidCallback? onEditTap;
  const ProfileNameCard({super.key, this.onEditTap});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
        final displayName = (user?.displayName).orDefault(AppStrings.petParent);
        final contact = user?.phoneNumber ?? user?.email ?? '';

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: smoothDecoration(
            cornerRadius: 24,
            color: AppColors.white,
            shadows: [
              BoxShadow(
                color: AppColors.shadowOverlay.withValues(alpha: 0.05),
                blurRadius: 43.78,
                offset: const Offset(0, 5.47),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.boldStyle700(
                          fontSize: 24, fontColor: AppColors.grey1000),
                    ),
                    if (contact.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        contact,
                        style: AppTextStyles.regularStyle400(
                            fontSize: 14, fontColor: AppColors.grey600),
                      ),
                    ],
                  ],
                ),
              ),
              GestureDetector(
                onTap: onEditTap,
                child: SvgPicture.asset(AppIcons.editIcon,
                    height: 22,
                    colorFilter: const ColorFilter.mode(
                        AppColors.secondaryCTA, BlendMode.srcIn)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Private helpers ──────────────────────────────────────────────

class _HeroPhotoArea extends StatelessWidget {
  final String? photoUrl;
  const _HeroPhotoArea({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        SizedBox(
          height: 360,
          width: double.infinity,
          child: hasPhoto
              ? Image.network(
                  photoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _Placeholder(),
                )
              : const _Placeholder(),
        ),
        Positioned(
          top: topPad + 8,
          left: 16,
          child: GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          AppIcons.addPhotoIcon,
          width: 48,
          height: 48,
          color: AppColors.white.withValues(alpha: 0.6),
          colorBlendMode: BlendMode.srcIn,
        ),
        const SizedBox(height: 10),
        Text(
          AppStrings.addPhoto,
          style: AppTextStyles.regularStyle400(
              fontSize: 14, fontColor: AppColors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}
