import 'package:flutter/material.dart';
import 'package:adventura/Chatbot/activityCard.dart';

class CircularGlowBorder extends StatefulWidget {
  final Widget child;

  const CircularGlowBorder({super.key, required this.child});

  @override
  State<CircularGlowBorder> createState() => _CircularGlowBorderState();
}

class _CircularGlowBorderState extends State<CircularGlowBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(); // loop forever
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
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: SweepGradient(
              colors: [
                Color.fromARGB(255, 255, 124, 1).withOpacity(0.6),
                Color.fromARGB(255, 255, 9, 9).withOpacity(0.6),
                Color.fromARGB(255, 255, 124, 1).withOpacity(0.6),
              ],
              startAngle: 0.0,
              endAngle: 6.28319, // 2π radians = full circle
              transform: GradientRotation(_controller.value * 6.28319),
            ),
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
