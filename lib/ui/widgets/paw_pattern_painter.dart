import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';

class PawPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw simple paw print patterns
    _drawPawPrints(canvas, size, paint);
  }

  void _drawPawPrints(Canvas canvas, Size size, Paint paint) {
    const double pawSize = 30.0;
    const spacing = 80.0;

    for (double x = 0; x < size.width + pawSize; x += spacing) {
      for (double y = 0; y < size.height + pawSize; y += spacing) {
        _drawSinglePawPrint(canvas, Offset(x, y), pawSize, paint);
      }
    }
  }

  void _drawSinglePawPrint(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();

    // Main pad (circle)
    path.addOval(Rect.fromCircle(center: center, radius: size * 0.3));

    // Toe pads (smaller circles)
    final toeRadius = size * 0.15;
    final toeOffset = size * 0.4;

    path.addOval(Rect.fromCircle(
      center: Offset(center.dx - toeOffset * 0.7, center.dy - toeOffset * 0.7),
      radius: toeRadius,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx + toeOffset * 0.7, center.dy - toeOffset * 0.7),
      radius: toeRadius,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx - toeOffset * 0.3, center.dy - toeOffset),
      radius: toeRadius,
    ));
    path.addOval(Rect.fromCircle(
      center: Offset(center.dx + toeOffset * 0.3, center.dy - toeOffset),
      radius: toeRadius,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
