import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

/// Full-width divider line that dips into a small V notch at its center,
/// used to separate the pet-type card from the sections below it.
class CreatePostSectionDivider extends StatelessWidget {
  const CreatePostSectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 20,
      width: double.infinity,
      child: CustomPaint(painter: _ChevronDividerPainter()),
    );
  }
}

class _ChevronDividerPainter extends CustomPainter {
  const _ChevronDividerPainter();

  static const double _notchHalfWidth = 12;
  static const double _notchDepth = 10;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final midY = size.height / 2;
    final centerX = size.width / 4;

    final path = Path()
      ..moveTo(0, midY)
      ..lineTo(centerX - _notchHalfWidth, midY)
      ..lineTo(centerX, midY + _notchDepth)
      ..lineTo(centerX + _notchHalfWidth, midY)
      ..lineTo(size.width, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
