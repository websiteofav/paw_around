import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

class AuthLogo extends StatelessWidget {
  final double size;

  const AuthLogo({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.pets,
          size: size * 0.5,
          color: AppColors.white,
        ),
      ),
    );
  }
}
