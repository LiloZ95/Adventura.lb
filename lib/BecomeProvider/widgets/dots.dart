import 'package:flutter/material.dart';

class StepDot extends StatelessWidget {
  final bool active;

  const StepDot({super.key, this.active = false});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 8,
      decoration: BoxDecoration(
        color: active
            ? Colors.blue
            : (isDarkMode ? Colors.grey[700] : Colors.grey[300]), // 🌙 Adapted
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
