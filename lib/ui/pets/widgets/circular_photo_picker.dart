import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_icons.dart';
import 'package:paw_around/constants/app_strings.dart';
import 'package:paw_around/constants/text_styles.dart';

class CircularPhotoPicker extends StatelessWidget {
  final String? imagePath;
  final bool isLoading;
  final VoidCallback onTap;
  final double size;

  const CircularPhotoPicker({
    super.key,
    this.imagePath,
    this.isLoading = false,
    required this.onTap,
    this.size = 140,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _CircularDashedBorderPainter(),
          child: ClipOval(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.neutral300),
                color: hasImage ? Colors.transparent : AppColors.white,
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : hasImage
                      ? _buildImage()
                      : _buildPlaceholder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return imagePath!.startsWith('http')
        ? Image.network(imagePath!, fit: BoxFit.cover)
        : Image.file(File(imagePath!), fit: BoxFit.cover);
  }

  Widget _buildPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(AppIcons.addPhotoIcon, width: 44, height: 44),
        const SizedBox(height: 6),
        Text(
          AppStrings.addPhoto,
          style: AppTextStyles.interRegularStyle400(
            fontSize: 14,
            fontColor: AppColors.grey1000,
          ),
        ),
      ],
    );
  }
}

class _CircularDashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final paint = Paint()
      ..color = AppColors.neutral300
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();
    final actualDashAngle = (dashWidth / circumference) * 2 * math.pi;
    final actualGapAngle = (dashSpace / circumference) * 2 * math.pi;

    double startAngle = -math.pi / 2;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle,
        actualDashAngle,
        false,
        paint,
      );
      startAngle += actualDashAngle + actualGapAngle;
    }
  }

  @override
  bool shouldRepaint(_CircularDashedBorderPainter oldDelegate) => false;
}
