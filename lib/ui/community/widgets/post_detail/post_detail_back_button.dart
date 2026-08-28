import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

class PostDetailBackButton extends StatelessWidget {
  final VoidCallback onTap;
  const PostDetailBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.shadowOverlay.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: onTap,
      ),
    );
  }
}
