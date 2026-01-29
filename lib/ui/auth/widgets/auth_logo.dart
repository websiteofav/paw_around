import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({
    super.key,
    this.size = 80,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          AppIcons.appIcon,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
