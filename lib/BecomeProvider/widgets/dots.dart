import 'package:flutter/material.dart';

class StepDot extends StatelessWidget {
  final bool active;

  const StepDot({super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.blue : Colors.grey[300],
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
