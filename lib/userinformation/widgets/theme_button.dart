import 'dart:ui';

import 'package:adventura/utils/snackbars.dart';
import 'package:flutter/material.dart';

class AppearanceFAB extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const AppearanceFAB({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.blue,
      onPressed: () {
        onToggle();
      },
      child: Icon(
        isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Colors.white,
      ),
    );
  }
}
