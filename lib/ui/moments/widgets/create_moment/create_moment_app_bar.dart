import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Title switches from "Create moment" to "New moment" once a photo has
/// been picked, matching the two-stage create-moment flow.
class CreateMomentAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final bool hasPhoto;

  const CreateMomentAppBar({super.key, required this.hasPhoto});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: Text(
        hasPhoto ? AppStrings.newMoment : AppStrings.createMomentTitle,
        style: AppTextStyles.semiBoldStyle600(fontSize: 17),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
