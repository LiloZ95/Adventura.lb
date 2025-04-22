import 'package:flutter/material.dart';

class RevealPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  RevealPainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1) // 👈 Make it translucent
      ..blendMode = BlendMode.srcOver; // 👈 Make it blend over content

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant RevealPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.color != color;
  }
}
