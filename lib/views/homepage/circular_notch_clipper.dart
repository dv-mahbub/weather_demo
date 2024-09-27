import 'package:flutter/material.dart';

class CircularNotchedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double notchRadius = 15.0;
    double centerWidth = size.width / 2;

    final path = Path();
    path.lineTo(centerWidth - notchRadius - 20, 0);

    path.arcToPoint(
      Offset(centerWidth + notchRadius + 20, 0),
      radius: Radius.circular(notchRadius),
      clockwise: false,
    );

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
