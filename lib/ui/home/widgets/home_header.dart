import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paw_around/bloc/auth/auth_bloc.dart';
import 'package:paw_around/bloc/auth/auth_state.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';
import 'package:paw_around/utils/utils.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onProfileTap;
  const HomeHeader({super.key, required this.onProfileTap});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final userName =
        authState is Authenticated ? authState.profile?.name ?? '' : '';
    final photoUrl =
        authState is Authenticated ? authState.profile?.photoUrl ?? '' : '';
    return Row(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(AppStrings.hiGreeting,
              style: AppTextStyles.interMediumStyle500(
                  fontSize: 18, fontColor: AppColors.grey700)),
          Text(userName,
              style: AppTextStyles.boldStyle700(
                  fontSize: 24, fontColor: AppColors.grey1000)),
        ]),
        const Spacer(),
        const Icon(Icons.notifications_outlined,
            size: 26, color: AppColors.grey1000),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onProfileTap,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage:
                photoUrl.isValidString ? NetworkImage(photoUrl) : null,
            child: !photoUrl.isValidString
                ? const Icon(Icons.person, color: AppColors.white, size: 22)
                : null,
          ),
        ),
      ],
    );
  }
}
