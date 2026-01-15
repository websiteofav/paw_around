import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/models/pets/pet_model.dart';

class CareAppBar extends StatelessWidget {
  final PetModel pet;
  final String screenTitle;
  final IconData? titleIcon;
  final VoidCallback? onNotificationTap;
  final bool enableNotification;

  const CareAppBar({
    super.key,
    required this.pet,
    required this.screenTitle,
    this.titleIcon,
    this.onNotificationTap,
    this.enableNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Back button, pet info, notification
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textPrimary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Pet avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.iconBgLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: pet.imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              pet.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.pets,
                                  color: AppColors.primary,
                                  size: 20,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.pets,
                            color: AppColors.primary,
                            size: 20,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Pet name and age
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pet.name,
                          style: AppTextStyles.semiBoldStyle600(
                              fontSize: 16, fontColor: AppColors.textPrimary),
                        ),
                        Text(
                          pet.ageString,
                          style: AppTextStyles.regularStyle400(
                              fontSize: 12, fontColor: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Icon(
                      enableNotification
                          ? Icons.notifications_outlined
                          : Icons.notifications_off_outlined,
                      color: enableNotification
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Screen title row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  if (titleIcon != null) ...[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.iconBgBeige,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        titleIcon,
                        color: const Color(0xFF8B7355),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    screenTitle,
                    style: AppTextStyles.semiBoldStyle600(
                        fontSize: 20, fontColor: AppColors.textPrimary),
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
