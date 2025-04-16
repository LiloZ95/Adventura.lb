import 'package:flutter/material.dart';

class CircularGlowBorder extends StatefulWidget {
  final Widget child;

  const CircularGlowBorder({super.key, required this.child});

  @override
  State<CircularGlowBorder> createState() => _CircularGlowBorderState();
}

class _CircularGlowBorderState extends State<CircularGlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return AnimatedBuilder(
    animation: _controller,
    builder: (_, __) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // Glow behind
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _GlowPainter(
                  opacity: _opacity.value,
                  angle: _controller.value * 6.28319,
                ),
              ),
            ),
          ),
          // Directly return the child (no inner container)
          widget.child,
        ],
      );
    },
  );
}

}

class _GlowPainter extends CustomPainter {
  final double opacity;
  final double angle;

  _GlowPainter({required this.opacity, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final glowPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          const Color(0xFFFFC107).withOpacity(opacity), // golden
          const Color(0xFFFF3D00).withOpacity(opacity), // hot orange-red
          const Color(0xFFFFC107).withOpacity(opacity),
        ],
        startAngle: 0,
        endAngle: 6.28319,
        transform: GradientRotation(angle),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5  // ✅ very tight line
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // ✅ very minimal blur

    final rrect = RRect.fromRectAndRadius(
      rect.deflate(5),  // ✅ barely shrinks the glow to hug the card
      Radius.circular(20),
    );

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter oldDelegate) =>
      oldDelegate.opacity != opacity || oldDelegate.angle != angle;
}

