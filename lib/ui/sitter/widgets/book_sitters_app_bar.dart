import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_routes.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class BookSittersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BookSittersAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      title: Text(
        AppStrings.petSittersTitle,
        style: AppTextStyles.semiBoldStyle600(
          fontSize: 18,
          fontColor: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.event_note_rounded,
              color: AppColors.secondaryCTA),
          onPressed: () => context.pushNamed(AppRoutes.myBookings),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
