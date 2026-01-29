import 'package:flutter/material.dart';

class CurvedTopClipper extends CustomClipper<Path> {
  final bool isInverted;

  CurvedTopClipper({this.isInverted = false});

  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 40);

    path.quadraticBezierTo(
      size.width / 2,
      isInverted ? size.height : 0,
      size.width,
      40,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
